#!/usr/bin/env bash
set -euo pipefail

# normalize-llm-punct.sh
#
# Replace common LLM / rich-text punctuation with plain ASCII.
#
# Examples:
#   ./normalize-llm-punct.sh README.md > README.clean.md
#   ./normalize-llm-punct.sh -i README.md
#   ./normalize-llm-punct.sh --dry-run --rglob "*.md"
#   ./normalize-llm-punct.sh -i --glob "*.md"
#   ./normalize-llm-punct.sh -i docs
#
# Notes:
#   - Quote glob patterns when passing them to --glob / --rglob.
#   - --glob uses shell-style glob matching from current directory.
#   - --rglob recursively scans files from current directory, then matches pattern
#     against both relative path and basename.
#   - Passing a directory as positional input recursively processes files below it.

program="${0##*/}"

inplace=false
dry_run=false
verbose=false

inputs=()
glob_patterns=()
rglob_patterns=()
files=()
stdin_requested=false

usage() {
  cat <<'EOF'
normalize-llm-punct.sh

Replace common LLM / rich-text punctuation with plain ASCII.

USAGE:
  normalize-llm-punct.sh [OPTIONS] [FILE|DIR|GLOB|-]...

OPTIONS:
  -i, --in-place       Modify files in place.
      --dry-run        Do not modify files. Print unified diff for changed files.
  -v, --verbose        Print progress information to stderr.
  -h, --help           Show this help.

      --glob PATTERN   Add files matching PATTERN non-recursively/shell-style.
                       Quote the pattern to prevent your shell from expanding it first.
                       Example: --glob "*.md"

      --rglob PATTERN  Recursively scan from current directory, then match PATTERN
                       against each relative path and basename.
                       Example: --rglob "*.md"

EXAMPLES:
  normalize-llm-punct.sh README.md > README.clean.md
  normalize-llm-punct.sh -i README.md
  normalize-llm-punct.sh --dry-run --rglob "*.md"
  normalize-llm-punct.sh -i --glob "*.md"
  normalize-llm-punct.sh -i docs
  cat input.md | normalize-llm-punct.sh > output.md

REPLACEMENTS:
  Smart quotes        -> ASCII quotes
  En/em/minus dashes  -> -
  Ellipsis            -> ...
  NBSP-like spaces    -> normal space
  Zero-width chars    -> removed
  Line bullet "· x"   -> "- x"
  Inline "A · B"      -> "A, B"
  Bullets             -> -
  Arrows              -> ->, <-, <->, =>
  Copyright marks     -> (C), (R), TM
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

log() {
  if "$verbose"; then
    printf '%s\n' "$*" >&2
  fi
}

has_glob_chars() {
  case "$1" in
    *'*'*|*'?'*|*'['*) return 0 ;;
    *) return 1 ;;
  esac
}

already_added() {
  local target="$1"
  local f
  for f in "${files[@]}"; do
    [[ "$f" == "$target" ]] && return 0
  done
  return 1
}

add_file() {
  local file="$1"

  [[ -f "$file" ]] || return 0

  if ! already_added "$file"; then
    files+=("$file")
  fi
}

add_dir_recursive() {
  local dir="$1"
  while IFS= read -r -d '' file; do
    add_file "$file"
  done < <(find "$dir" -type f -print0)
}

expand_glob_pattern() {
  local pattern="$1"
  local matched=false
  local path

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ -f "$path" ]]; then
      add_file "$path"
      matched=true
    elif [[ -d "$path" ]]; then
      add_dir_recursive "$path"
      matched=true
    fi
  done < <(compgen -G "$pattern" || true)

  if ! "$matched"; then
    log "no matches for glob: $pattern"
  fi
}

expand_rglob_pattern() {
  local pattern="$1"
  local matched=false
  local file rel base

  while IFS= read -r -d '' file; do
    rel="${file#./}"
    base="${rel##*/}"

    # Intentionally unquoted RHS: pattern matching in [[ ... == pattern ]].
    if [[ "$rel" == $pattern || "$base" == $pattern ]]; then
      add_file "$file"
      matched=true
    fi
  done < <(find . -type f -print0)

  if ! "$matched"; then
    log "no matches for rglob: $pattern"
  fi
}

normalize_stream() {
  perl -CSDA -Mutf8 -pe '
    s/^\s*\z// if 0;                 # keep perl -pe happy with UTF-8 mode

    s/^(\s*)\x{00B7}\s+/$1- /g;      # bullet: · item -> - item
    s/\s*\x{00B7}\s*/, /g;           # inline: A · B -> A, B

    s/\x{2018}/\x{27}/g;             # left single quote
    s/\x{2019}/\x{27}/g;             # right single quote / apostrophe
    s/\x{201A}/\x{27}/g;
    s/\x{201B}/\x{27}/g;

    s/\x{201C}/\x{22}/g;             # left double quote
    s/\x{201D}/\x{22}/g;             # right double quote
    s/\x{201E}/\x{22}/g;
    s/\x{201F}/\x{22}/g;

    s/\x{2010}/-/g;                  # hyphen
    s/\x{2011}/-/g;                  # non-breaking hyphen
    s/\x{2012}/-/g;                  # figure dash
    s/\x{2013}/-/g;                  # en dash
    s/\x{2014}/-/g;                  # em dash
    s/\x{2015}/-/g;                  # horizontal bar
    s/\x{2212}/-/g;                  # minus sign

    s/\x{2026}/.../g;                # ellipsis

    s/\x{00A0}/ /g;                  # non-breaking space
    s/\x{2007}/ /g;                  # figure space
    s/\x{202F}/ /g;                  # narrow no-break space

    s/\x{200B}//g;                   # zero-width space
    s/\x{200C}//g;                   # zero-width non-joiner
    s/\x{200D}//g;                   # zero-width joiner
    s/\x{2060}//g;                   # word joiner
    s/\x{FEFF}//g;                   # BOM / zero-width no-break space

    s/^(\s*)[\x{2022}\x{25E6}\x{2043}]\s+/$1- /g;  # bullet lines
    s/\x{2022}/-/g;                  # bullet
    s/\x{25E6}/-/g;                  # white bullet
    s/\x{2043}/-/g;                  # hyphen bullet

    s/\x{2192}/->/g;                 # right arrow
    s/\x{2190}/<-/g;                 # left arrow
    s/\x{2194}/<->/g;                # left-right arrow
    s/\x{21D2}/=>/g;                 # double right arrow

    s/\x{00AE}/(R)/g;                # registered
    s/\x{00A9}/(C)/g;                # copyright
    s/\x{2122}/TM/g;                 # trademark
  '
}

process_file() {
  local file="$1"
  local tmp

  tmp="$(mktemp "${TMPDIR:-/tmp}/${program}.XXXXXX")"

  if ! normalize_stream < "$file" > "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  if cmp -s "$file" "$tmp"; then
    log "unchanged: $file"
    rm -f "$tmp"
    return 0
  fi

  if "$dry_run"; then
    printf '\n--- would change: %s ---\n' "$file" >&2
    diff -u "$file" "$tmp" || true
    rm -f "$tmp"
    return 0
  fi

  if "$inplace"; then
    cat "$tmp" > "$file"
    log "updated: $file"
    rm -f "$tmp"
    return 0
  fi

  normalize_stream < "$file"
  rm -f "$tmp"
}

while (($#)); do
  case "$1" in
    -i|--in-place)
      inplace=true
      ;;
    --dry-run)
      dry_run=true
      ;;
    -v|--verbose)
      verbose=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --glob)
      shift
      [[ "${1:-}" ]] || die "--glob requires a pattern"
      glob_patterns+=("$1")
      ;;
    --glob=*)
      glob_patterns+=("${1#--glob=}")
      ;;
    --rglob)
      shift
      [[ "${1:-}" ]] || die "--rglob requires a pattern"
      rglob_patterns+=("$1")
      ;;
    --rglob=*)
      rglob_patterns+=("${1#--rglob=}")
      ;;
    --)
      shift
      while (($#)); do
        inputs+=("$1")
        shift
      done
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      inputs+=("$1")
      ;;
  esac
  shift
done

for pattern in "${glob_patterns[@]}"; do
  expand_glob_pattern "$pattern"
done

for pattern in "${rglob_patterns[@]}"; do
  expand_rglob_pattern "$pattern"
done

for input in "${inputs[@]}"; do
  if [[ "$input" == "-" ]]; then
    stdin_requested=true
  elif [[ -f "$input" ]]; then
    add_file "$input"
  elif [[ -d "$input" ]]; then
    add_dir_recursive "$input"
  elif has_glob_chars "$input"; then
    expand_glob_pattern "$input"
  else
    log "not found or unsupported: $input"
  fi
done

if ((${#files[@]} == 0)) && ! "$stdin_requested"; then
  if "$inplace"; then
    die "--in-place requires file, directory, --glob, or --rglob input"
  fi
  normalize_stream
  exit 0
fi

if "$stdin_requested"; then
  if "$inplace"; then
    die "--in-place cannot be used with stdin"
  fi
  normalize_stream
fi

for file in "${files[@]}"; do
  process_file "$file"
done
