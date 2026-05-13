#!/usr/bin/env bash
set -euo pipefail

# data-telescope: single-file Telescope-like picker for structured data files.
# Requires: bash, python3, fzf
# Optional: nvim, openpyxl for .xlsx parsing, pbcopy/wl-copy/xclip for copy-path.

# Prefer an available UTF-8 locale, but do not force LC_ALL.
# Python also gets PYTHONUTF8=1, so parsing stays Unicode-safe even on minimal systems.
if [[ -z "${LANG:-}" || "${LANG:-}" == "C" || "${LANG:-}" == "POSIX" ]]; then
  if locale -a 2>/dev/null | grep -qi '^C\.UTF-8$'; then
    export LANG="C.UTF-8"
  elif locale -a 2>/dev/null | grep -qi '^en_US\.UTF-8$'; then
    export LANG="en_US.UTF-8"
  else
    export LANG="${LANG:-C}"
  fi
fi
export PYTHONUTF8=1

SELF="${BASH_SOURCE[0]}"
if [[ "$SELF" != /* ]]; then
  SELF="$PWD/$SELF"
fi

FIELD_DELIM=$'\x1f'
DEFAULT_ROOT="."

usage() {
  cat <<'EOF'
data-telescope

Usage:
  data-telescope [ROOT]
  data-telescope pick [ROOT]
  data-telescope scan [ROOT]
  data-telescope preview --path PATH --kind KIND --loc LOC --query QUERY
  data-telescope open --path PATH --kind KIND --loc LOC
  data-telescope doctor

Description:
  Single-file external Telescope-style picker for structured data values.

  - Recursively scans: .json, .jsonl, .ndjson, .csv, .tsv, .xlsx
  - Fuzzy-searches extracted values via fzf
  - Shows live preview with query highlighting
  - Enter opens nvim, then returns to same fzf session after :wq
  - .xlsx is search/preview/export only; original xlsx editing is out of scope

Keybindings inside picker:
  Enter   Open selected result in $EDITOR or nvim, then return to picker
  Ctrl-o  Open original file with system opener
  Ctrl-y  Copy original path
  Ctrl-r  Reload scan
  Esc     Quit

Environment:
  EDITOR                         Editor for Enter action. Default: nvim
  DATA_TELESCOPE_MAX_ROWS_PER_FILE  Per-file row cap. Default: 5000
  DATA_TELESCOPE_INCLUDE_HIDDEN     1 to include hidden dirs/files. Default: 0
  DATA_TELESCOPE_NO_DEFAULT_IGNORES 1 to stop ignoring .git/node_modules/etc.

Optional xlsx support:
  python3 -m pip install openpyxl
  or
  uv tool install openpyxl is NOT enough for system python; prefer project/user pip.
EOF
}

have() { command -v "$1" >/dev/null 2>&1; }

quote() {
  printf '%q' "$1"
}

copy_cmd() {
  if have pbcopy; then
    printf 'pbcopy'
  elif have wl-copy; then
    printf 'wl-copy'
  elif have xclip; then
    printf 'xclip -selection clipboard'
  else
    printf ''
  fi
}

open_original() {
  local path="$1"
  if [[ "${OSTYPE:-}" == darwin* ]] && have open; then
    open "$path" >/dev/null 2>&1 || true
  elif have xdg-open; then
    xdg-open "$path" >/dev/null 2>&1 || true
  else
    printf 'No system opener found for: %s\n' "$path" >&2
  fi
}

require_picker_deps() {
  if ! have fzf; then
    echo "error: fzf is required" >&2
    exit 1
  fi
  if ! have python3; then
    echo "error: python3 is required" >&2
    exit 1
  fi
}

run_pick() {
  require_picker_deps

  local root="${1:-$DEFAULT_ROOT}"
  local qself qroot qcopy opener
  qself="$(quote "$SELF")"
  qroot="$(quote "$root")"
  opener="$(quote "$SELF") open-original --path"

  local copy_bind
  local copier
  copier="$(copy_cmd)"
  if [[ -n "$copier" ]]; then
    copy_bind="ctrl-y:execute-silent(printf %s {1} | $copier)"
  else
    copy_bind="ctrl-y:execute-silent(printf 'no clipboard command found\n' >/dev/stderr)"
  fi

  # Force bash for fzf child commands so printf %q quoting stays predictable.
  SHELL="${BASH:-/bin/bash}" "$SELF" scan "$root" | \
    fzf \
      --ansi \
      --delimiter="$FIELD_DELIM" \
      --with-nth='4..,1,3' \
      --height='95%' \
      --layout=reverse \
      --border \
      --prompt='data> ' \
      --preview="$qself preview --path {1} --kind {2} --loc {3} --query {q}" \
      --preview-window='right:70%:wrap' \
      --bind="enter:execute($qself open --path {1} --kind {2} --loc {3})" \
      --bind="ctrl-o:execute($qself open-original --path {1})" \
      --bind="$copy_bind" \
      --bind="ctrl-r:reload($qself scan $qroot)"
}

run_scan() {
  local root="${1:-$DEFAULT_ROOT}"
  python3 - "$root" "$FIELD_DELIM" <<'PY'
import csv
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Iterable

root = Path(sys.argv[1]).expanduser()
delim = sys.argv[2]
max_rows = int(os.environ.get("DATA_TELESCOPE_MAX_ROWS_PER_FILE", "5000"))
include_hidden = os.environ.get("DATA_TELESCOPE_INCLUDE_HIDDEN", "0") == "1"
no_default_ignores = os.environ.get("DATA_TELESCOPE_NO_DEFAULT_IGNORES", "0") == "1"

EXTS = {".json", ".jsonl", ".ndjson", ".csv", ".tsv", ".xlsx"}
DEFAULT_IGNORED_DIRS = {
    ".git", ".hg", ".svn", "node_modules", ".venv", "venv", "__pycache__",
    ".mypy_cache", ".pytest_cache", ".ruff_cache", ".tox", ".idea", ".vscode",
}
CONTROL_RE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")


def clean(s: Any) -> str:
    if s is None:
        return ""
    if not isinstance(s, str):
        s = str(s)
    s = s.replace("\t", " ").replace("\r", " ").replace("\n", " ")
    s = CONTROL_RE.sub("�", s)
    return s.strip()


def emit(path: Path, kind: str, loc: str, text: str) -> None:
    text = clean(text)
    if not text:
        return
    # Avoid breaking the field protocol. Newlines already removed above.
    fields = [str(path), kind, clean(loc), text]
    sys.stdout.write(delim.join(fields) + "\n")


def flatten(value: Any, prefix: str = "", limit: int = 120) -> list[str]:
    out: list[str] = []

    def walk(v: Any, p: str) -> None:
        if len(out) >= limit:
            return
        if isinstance(v, dict):
            for k, vv in v.items():
                key = clean(k)
                np = f"{p}.{key}" if p else key
                walk(vv, np)
        elif isinstance(v, list):
            # For arrays of scalars, keep compact value. For arrays of objects, walk first few.
            if all(not isinstance(x, (dict, list)) for x in v[:20]):
                joined = ", ".join(clean(x) for x in v[:20] if clean(x))
                if joined:
                    out.append(f"{p}=[{joined}]")
            else:
                for i, item in enumerate(v[:20]):
                    walk(item, f"{p}[{i}]" if p else f"[{i}]")
        else:
            sv = clean(v)
            if sv:
                out.append(f"{p}={sv}" if p else sv)

    walk(value, prefix)
    return out


def row_to_text(headers: list[str] | None, row: list[Any], max_cols: int = 80) -> str:
    parts: list[str] = []
    if headers:
        for i, val in enumerate(row[:max_cols]):
            sval = clean(val)
            if not sval:
                continue
            key = clean(headers[i]) if i < len(headers) and clean(headers[i]) else f"col{i+1}"
            parts.append(f"{key}={sval}")
    else:
        for i, val in enumerate(row[:max_cols]):
            sval = clean(val)
            if sval:
                parts.append(f"col{i+1}={sval}")
    return " ".join(parts)


def sniff_has_header(row: list[str]) -> bool:
    if not row:
        return False
    nonempty = [clean(x) for x in row if clean(x)]
    if not nonempty:
        return False
    # Conservative: treat first row as header if most cells look label-like, not long prose.
    shortish = sum(1 for x in nonempty if len(x) <= 40)
    numericish = sum(1 for x in nonempty if re.fullmatch(r"[-+]?\d+(\.\d+)?", x))
    return shortish >= max(1, int(len(nonempty) * 0.7)) and numericish == 0


def scan_csv(path: Path, delimiter_char: str) -> None:
    try:
        with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as f:
            sample = f.read(8192)
            f.seek(0)
            try:
                dialect = csv.Sniffer().sniff(sample, delimiters=",\t;|")
            except csv.Error:
                dialect = csv.excel_tab if delimiter_char == "\t" else csv.excel
                dialect.delimiter = delimiter_char
            reader = csv.reader(f, dialect)
            first = next(reader, None)
            if first is None:
                return
            headers = first if sniff_has_header(first) else None
            if headers is None:
                text = row_to_text(None, first)
                emit(path, "tsv" if delimiter_char == "\t" else "csv", "1", text)
                row_number = 1
            else:
                row_number = 1
            count = 0
            for row in reader:
                row_number += 1
                text = row_to_text(headers, row)
                emit(path, "tsv" if delimiter_char == "\t" else "csv", str(row_number), text)
                count += 1
                if count >= max_rows:
                    break
    except Exception as e:
        emit(path, "error", "0", f"CSV parse error: {type(e).__name__}: {e}")


def scan_jsonl(path: Path, kind: str) -> None:
    try:
        with path.open("r", encoding="utf-8-sig", errors="replace") as f:
            for i, line in enumerate(f, start=1):
                if i > max_rows:
                    break
                raw = line.strip()
                if not raw:
                    continue
                try:
                    obj = json.loads(raw)
                    text = " ".join(flatten(obj))
                except Exception:
                    text = raw
                emit(path, kind, str(i), text)
    except Exception as e:
        emit(path, "error", "0", f"JSONL read error: {type(e).__name__}: {e}")


def scan_json(path: Path) -> None:
    try:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        obj = json.loads(text)
    except Exception as e:
        emit(path, "error", "0", f"JSON parse error: {type(e).__name__}: {e}")
        return

    count = 0
    if isinstance(obj, list):
        for i, item in enumerate(obj):
            emit(path, "json", f"$[{i}]", " ".join(flatten(item)))
            count += 1
            if count >= max_rows:
                break
    elif isinstance(obj, dict):
        # Emit top-level object plus individual top-level containers for better result granularity.
        emit(path, "json", "$", " ".join(flatten(obj)))
        count += 1
        for k, v in obj.items():
            if count >= max_rows:
                break
            if isinstance(v, list):
                for i, item in enumerate(v):
                    emit(path, "json", f"$.{k}[{i}]", " ".join(flatten(item, str(k))))
                    count += 1
                    if count >= max_rows:
                        break
            elif isinstance(v, dict):
                emit(path, "json", f"$.{k}", " ".join(flatten(v, str(k))))
                count += 1
    else:
        emit(path, "json", "$", clean(obj))


def scan_xlsx(path: Path) -> None:
    try:
        from openpyxl import load_workbook  # type: ignore
    except Exception:
        emit(path, "xlsx", "0", "xlsx support missing: install Python package openpyxl")
        return

    try:
        wb = load_workbook(path, read_only=True, data_only=True)
        emitted = 0
        for ws in wb.worksheets:
            rows = ws.iter_rows(values_only=True)
            first = next(rows, None)
            if first is None:
                continue
            first_list = list(first)
            headers = [clean(x) for x in first_list] if sniff_has_header([clean(x) for x in first_list]) else None
            if headers is None:
                emit(path, "xlsx", f"{ws.title}!1", row_to_text(None, first_list))
                emitted += 1
            for idx, row in enumerate(rows, start=2):
                text = row_to_text(headers, list(row))
                emit(path, "xlsx", f"{ws.title}!{idx}", text)
                emitted += 1
                if emitted >= max_rows:
                    return
    except Exception as e:
        emit(path, "error", "0", f"XLSX parse error: {type(e).__name__}: {e}")


def should_skip_dir(dir_path: Path) -> bool:
    name = dir_path.name
    if not include_hidden and name.startswith("."):
        return True
    if not no_default_ignores and name in DEFAULT_IGNORED_DIRS:
        return True
    return False


def iter_files(base: Path) -> Iterable[Path]:
    if base.is_file():
        if base.suffix.lower() in EXTS:
            yield base
        return
    for current, dirs, files in os.walk(base):
        cur = Path(current)
        dirs[:] = [d for d in dirs if not should_skip_dir(cur / d)]
        for filename in files:
            if not include_hidden and filename.startswith("."):
                continue
            p = cur / filename
            if p.suffix.lower() in EXTS:
                yield p


def main() -> None:
    if not root.exists():
        sys.stderr.write(f"error: path does not exist: {root}\n")
        sys.exit(1)
    for path in iter_files(root):
        ext = path.suffix.lower()
        if ext == ".csv":
            scan_csv(path, ",")
        elif ext == ".tsv":
            scan_csv(path, "\t")
        elif ext in {".jsonl", ".ndjson"}:
            scan_jsonl(path, ext.lstrip("."))
        elif ext == ".json":
            scan_json(path)
        elif ext == ".xlsx":
            scan_xlsx(path)


if __name__ == "__main__":
    main()
PY
}

run_preview() {
  local path="" kind="" loc="" query=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --path) path="${2:-}"; shift 2 ;;
      --kind) kind="${2:-}"; shift 2 ;;
      --loc) loc="${2:-}"; shift 2 ;;
      --query) query="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  python3 - "$path" "$kind" "$loc" "$query" <<'PY'
import csv
import json
import os
import re
import sys
from pathlib import Path
from typing import Any

path = Path(sys.argv[1])
kind = sys.argv[2]
loc = sys.argv[3]
query = sys.argv[4]

RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
REV = "\033[7m"
CYAN = "\033[36m"
YELLOW = "\033[33m"
RED = "\033[31m"
GREEN = "\033[32m"

CONTROL_RE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")


def clean(s: Any) -> str:
    if s is None:
        return ""
    if not isinstance(s, str):
        s = str(s)
    s = s.replace("\r", " ").replace("\n", " ")
    s = CONTROL_RE.sub("�", s)
    return s


def tokens_from_query(q: str) -> list[str]:
    out: list[str] = []
    for raw in q.split():
        t = raw.strip().strip('"\'')
        # Strip common fzf operators for literal preview highlight.
        while t.startswith(("!", "^")):
            t = t[1:]
        if t.endswith("$"):
            t = t[:-1]
        if not t or t == "|":
            continue
        if len(t) > 80:
            t = t[:80]
        out.append(t)
    # Longest first avoids nested partial highlights.
    return sorted(set(out), key=len, reverse=True)


def highlight(text: str) -> str:
    text = clean(text)
    toks = tokens_from_query(query)
    if not toks:
        return text
    # Regex literal highlight. Safe for Unicode; avoids interpreting query as regex.
    for tok in toks:
        try:
            pat = re.compile(re.escape(tok), re.IGNORECASE)
            text = pat.sub(lambda m: f"{REV}{m.group(0)}{RESET}", text)
        except re.error:
            pass
    return text


def print_header() -> None:
    print(f"{BOLD}{CYAN}{path}{RESET}")
    print(f"{DIM}kind={kind} loc={loc} query={query!r}{RESET}")
    print("─" * 80)


def parse_int_loc(default: int = 1) -> int:
    try:
        return max(1, int(loc))
    except Exception:
        return default


def preview_text_lines(center_line: int = 1, radius: int = 25) -> None:
    print_header()
    try:
        lines = path.read_text(encoding="utf-8-sig", errors="replace").splitlines()
    except Exception as e:
        print(f"{RED}read error: {type(e).__name__}: {e}{RESET}")
        return
    if not lines:
        print(f"{DIM}<empty>{RESET}")
        return
    start = max(1, center_line - radius)
    end = min(len(lines), center_line + radius)
    width = len(str(end))
    for no in range(start, end + 1):
        marker = ">" if no == center_line else " "
        prefix = f"{YELLOW}{marker}{str(no).rjust(width)}│{RESET} "
        print(prefix + highlight(lines[no - 1]))


def sniff_has_header(row: list[str]) -> bool:
    nonempty = [x.strip() for x in row if x and x.strip()]
    if not nonempty:
        return False
    shortish = sum(1 for x in nonempty if len(x) <= 40)
    numericish = sum(1 for x in nonempty if re.fullmatch(r"[-+]?\d+(\.\d+)?", x))
    return shortish >= max(1, int(len(nonempty) * 0.7)) and numericish == 0


def row_to_text(headers: list[str] | None, row: list[Any], max_cols: int = 80) -> str:
    parts: list[str] = []
    if headers:
        for i, val in enumerate(row[:max_cols]):
            sval = clean(val).strip()
            if not sval:
                continue
            key = headers[i].strip() if i < len(headers) and headers[i].strip() else f"col{i+1}"
            parts.append(f"{key}={sval}")
    else:
        for i, val in enumerate(row[:max_cols]):
            sval = clean(val).strip()
            if sval:
                parts.append(f"col{i+1}={sval}")
    return " ".join(parts)


def preview_csv(delimiter_char: str) -> None:
    print_header()
    target = parse_int_loc()
    try:
        with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as f:
            sample = f.read(8192)
            f.seek(0)
            try:
                dialect = csv.Sniffer().sniff(sample, delimiters=",\t;|")
            except csv.Error:
                dialect = csv.excel_tab if delimiter_char == "\t" else csv.excel
                dialect.delimiter = delimiter_char
            rows = list(csv.reader(f, dialect))
    except Exception as e:
        print(f"{RED}CSV parse error: {type(e).__name__}: {e}{RESET}")
        return
    if not rows:
        print(f"{DIM}<empty>{RESET}")
        return
    headers = rows[0] if sniff_has_header(rows[0]) else None
    start = max(1, target - 12)
    end = min(len(rows), target + 12)
    width = len(str(end))
    if headers:
        print(f"{DIM}headers: {highlight(' | '.join(headers))}{RESET}")
        print("─" * 80)
    for row_no in range(start, end + 1):
        marker = ">" if row_no == target else " "
        text = row_to_text(headers, rows[row_no - 1])
        print(f"{YELLOW}{marker}{str(row_no).rjust(width)}│{RESET} {highlight(text)}")


def get_json_path(obj: Any, expr: str) -> Any:
    if expr == "$":
        return obj
    cur = obj
    # Supports simple paths emitted by scanner: $[i], $.key, $.key[i]
    rest = expr[1:] if expr.startswith("$") else expr
    token_re = re.compile(r"(?:\.([^\.\[]+))|(?:\[(\d+)\])")
    for m in token_re.finditer(rest):
        key, idx = m.group(1), m.group(2)
        if key is not None:
            if isinstance(cur, dict):
                cur = cur.get(key)
            else:
                return None
        elif idx is not None:
            if isinstance(cur, list):
                i = int(idx)
                cur = cur[i] if 0 <= i < len(cur) else None
            else:
                return None
    return cur


def preview_json() -> None:
    print_header()
    try:
        obj = json.loads(path.read_text(encoding="utf-8-sig", errors="replace"))
        selected = get_json_path(obj, loc)
        if selected is None:
            selected = obj
        pretty = json.dumps(selected, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"{RED}JSON parse error: {type(e).__name__}: {e}{RESET}")
        preview_text_lines(1, 40)
        return
    lines = pretty.splitlines()
    for i, line in enumerate(lines[:220], start=1):
        print(f"{YELLOW}{str(i).rjust(3)}│{RESET} {highlight(line)}")
    if len(lines) > 220:
        print(f"{DIM}… truncated {len(lines) - 220} lines{RESET}")


def preview_jsonl() -> None:
    target = parse_int_loc()
    preview_text_lines(target, 20)
    try:
        selected = path.read_text(encoding="utf-8-sig", errors="replace").splitlines()[target - 1]
        obj = json.loads(selected)
        print("─" * 80)
        print(f"{BOLD}{GREEN}selected line parsed{RESET}")
        pretty = json.dumps(obj, ensure_ascii=False, indent=2)
        for line in pretty.splitlines()[:160]:
            print(highlight(line))
    except Exception:
        pass


def parse_xlsx_loc() -> tuple[str, int]:
    if "!" not in loc:
        return "", 1
    sheet, row_s = loc.rsplit("!", 1)
    try:
        row = max(1, int(row_s))
    except Exception:
        row = 1
    return sheet, row


def preview_xlsx() -> None:
    print_header()
    try:
        from openpyxl import load_workbook  # type: ignore
    except Exception:
        print(f"{RED}xlsx support missing: install Python package openpyxl{RESET}")
        return
    sheet_name, target = parse_xlsx_loc()
    try:
        wb = load_workbook(path, read_only=True, data_only=True)
        ws = wb[sheet_name] if sheet_name in wb.sheetnames else wb.worksheets[0]
        rows_iter = ws.iter_rows(values_only=True)
        rows: list[list[Any]] = []
        start = max(1, target - 12)
        end = target + 12
        first = next(rows_iter, None)
        headers = [clean(x) for x in first] if first and sniff_has_header([clean(x) for x in first]) else None
        if first is not None and start <= 1 <= end:
            rows.append([1, list(first)])
        for idx, row in enumerate(rows_iter, start=2):
            if idx > end:
                break
            if idx >= start:
                rows.append([idx, list(row)])
        if headers:
            print(f"{DIM}sheet={ws.title} headers: {highlight(' | '.join(headers))}{RESET}")
            print("─" * 80)
        width = len(str(end))
        for row_no, row in rows:
            marker = ">" if row_no == target else " "
            text = row_to_text(headers, row)
            print(f"{YELLOW}{marker}{str(row_no).rjust(width)}│{RESET} {highlight(text)}")
    except Exception as e:
        print(f"{RED}XLSX preview error: {type(e).__name__}: {e}{RESET}")


def main() -> None:
    if kind == "csv":
        preview_csv(",")
    elif kind == "tsv":
        preview_csv("\t")
    elif kind in {"jsonl", "ndjson"}:
        preview_jsonl()
    elif kind == "json":
        preview_json()
    elif kind == "xlsx":
        preview_xlsx()
    else:
        preview_text_lines(parse_int_loc(), 25)


if __name__ == "__main__":
    main()
PY
}

run_open() {
  local path="" kind="" loc=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --path) path="${2:-}"; shift 2 ;;
      --kind) kind="${2:-}"; shift 2 ;;
      --loc) loc="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  local editor="${EDITOR:-nvim}"
  if ! have "$editor"; then
    if have nvim; then
      editor="nvim"
    elif have vim; then
      editor="vim"
    else
      echo "error: no editor found. Set EDITOR or install nvim/vim." >&2
      printf 'Press Enter to return to fzf... ' >&2
      read -r _ || true
      return 0
    fi
  fi

  case "$kind" in
    csv|tsv|jsonl|ndjson)
      local line="1"
      if [[ "$loc" =~ ^[0-9]+$ ]]; then line="$loc"; fi
      "$editor" "+$line" "$path"
      ;;
    json)
      "$editor" "$path"
      ;;
    xlsx)
      local tmp
      tmp="$(mktemp -t data-telescope-xlsx.XXXXXX.csv)"
      if "$SELF" export-xlsx --path "$path" --loc "$loc" > "$tmp"; then
        "$editor" "$tmp"
      else
        rm -f "$tmp"
        echo "error: failed to export xlsx. Install openpyxl for xlsx export." >&2
        printf 'Press Enter to return to fzf... ' >&2
        read -r _ || true
      fi
      ;;
    *)
      "$editor" "$path"
      ;;
  esac
}

run_export_xlsx() {
  local path="" loc=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --path) path="${2:-}"; shift 2 ;;
      --loc) loc="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done

  python3 - "$path" "$loc" <<'PY'
import csv
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
loc = sys.argv[2]

try:
    from openpyxl import load_workbook  # type: ignore
except Exception as e:
    sys.stderr.write(f"openpyxl import error: {e}\n")
    sys.exit(1)

sheet_name = ""
if "!" in loc:
    sheet_name = loc.rsplit("!", 1)[0]

try:
    wb = load_workbook(path, read_only=True, data_only=True)
    ws = wb[sheet_name] if sheet_name in wb.sheetnames else wb.worksheets[0]
    writer = csv.writer(sys.stdout)
    for row in ws.iter_rows(values_only=True):
        writer.writerow(["" if x is None else x for x in row])
except Exception as e:
    sys.stderr.write(f"xlsx export error: {type(e).__name__}: {e}\n")
    sys.exit(1)
PY
}

run_doctor() {
  echo "data-telescope doctor"
  echo
  printf 'bash:   %s\n' "${BASH_VERSION:-unknown}"
  if have python3; then
    printf 'python: %s\n' "$(python3 --version 2>&1)"
  else
    printf 'python: missing\n'
  fi
  if have fzf; then
    printf 'fzf:    %s\n' "$(fzf --version 2>/dev/null | head -n 1)"
  else
    printf 'fzf:    missing\n'
  fi
  if have "${EDITOR:-nvim}"; then
    printf 'editor: %s\n' "${EDITOR:-nvim}"
  elif have nvim; then
    printf 'editor: nvim\n'
  elif have vim; then
    printf 'editor: vim\n'
  else
    printf 'editor: missing\n'
  fi
  python3 - <<'PY' || true
try:
    import openpyxl  # type: ignore
    print(f"openpyxl: {getattr(openpyxl, '__version__', 'installed')}")
except Exception:
    print("openpyxl: missing; .xlsx search/preview/export disabled")
PY
  if [[ -n "$(copy_cmd)" ]]; then
    printf 'clipboard: %s\n' "$(copy_cmd)"
  else
    printf 'clipboard: missing\n'
  fi
}

cmd="${1:-pick}"
case "$cmd" in
  -h|--help|help)
    usage
    ;;
  pick)
    shift || true
    run_pick "${1:-$DEFAULT_ROOT}"
    ;;
  scan)
    shift || true
    run_scan "${1:-$DEFAULT_ROOT}"
    ;;
  preview)
    shift || true
    run_preview "$@"
    ;;
  open)
    shift || true
    run_open "$@"
    ;;
  open-original)
    shift || true
    p=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --path) p="${2:-}"; shift 2 ;;
        *) shift ;;
      esac
    done
    open_original "$p"
    ;;
  export-xlsx)
    shift || true
    run_export_xlsx "$@"
    ;;
  doctor)
    run_doctor
    ;;
  *)
    # Default ergonomic path: data-telescope /some/root
    run_pick "$cmd"
    ;;
esac
