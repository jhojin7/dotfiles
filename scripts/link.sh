#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mode="dry-run"
use_stow=false

MAP_ENTRIES=(
  "zsh|config/zsh/zshrc|zshrc|$HOME/.zshrc"
  "profile|config/profile/profile|profile|$HOME/.profile"
  "nvim|config/nvim|nvim/nvim|$HOME/.config/nvim"
  "tmux|config/tmux/tmux.conf|tmux/tmux.conf|$HOME/.config/tmux/tmux.conf"
  "ghostty|config/ghostty/config|ghostty/config|$HOME/.config/ghostty/config"
  "opencode|config/opencode/opencode.json|opencode/opencode.json|$HOME/.config/opencode/opencode.json"
)

STOW_PACKAGES=(zsh profile nvim tmux ghostty opencode)

usage() {
  cat <<'EOF'
scripts/link.sh

Create and manage symlinks for tracked config files.

Usage:
  ./scripts/link.sh --dry-run
  ./scripts/link.sh --apply
  ./scripts/link.sh --status
  ./scripts/link.sh --stow --dry-run
  ./scripts/link.sh --stow --apply

Notes:
  - Default mode is --dry-run.
  - Explicit mode prefers config/ sources and falls back to current legacy paths
    until the config/ migration is complete.
  - The script never overwrites regular files or directories.
EOF
}

log_line() {
  local level="$1"
  shift
  printf '%s %s\n' "$level" "$*"
}

resolve_source() {
  local preferred_rel="$1"
  local legacy_rel="$2"
  local preferred_abs="$REPO_ROOT/$preferred_rel"
  local legacy_abs="$REPO_ROOT/$legacy_rel"

  if [[ -e "$preferred_abs" ]]; then
    printf '%s|config\n' "$preferred_abs"
    return 0
  fi

  if [[ -e "$legacy_abs" ]]; then
    printf '%s|legacy\n' "$legacy_abs"
    return 0
  fi

  return 1
}

ensure_parent_dir() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
}

process_explicit_entry() {
  local entry="$1"
  local name preferred_rel legacy_rel target
  IFS='|' read -r name preferred_rel legacy_rel target <<<"$entry"

  local resolved source source_kind
  if ! resolved="$(resolve_source "$preferred_rel" "$legacy_rel")"; then
    log_line "FAIL" "$name missing source: $preferred_rel (fallback: $legacy_rel)"
    return 1
  fi

  IFS='|' read -r source source_kind <<<"$resolved"

  if [[ "$source_kind" == "legacy" ]]; then
    log_line "WARN" "$name using legacy source $legacy_rel until config/ migration exists"
  fi

  if [[ ! -e "$target" && ! -L "$target" ]]; then
    case "$mode" in
      dry-run)
        log_line "PLAN" "$target -> $source"
        ;;
      status)
        log_line "WARN" "$target missing"
        ;;
      apply)
        ensure_parent_dir "$target"
        ln -s "$source" "$target"
        log_line "PASS" "linked $target -> $source"
        ;;
    esac
    return 0
  fi

  if [[ -L "$target" && ! -e "$target" ]]; then
    log_line "FAIL" "$target is a broken symlink; remove or repair it first"
    return 1
  fi

  if [[ -L "$target" ]]; then
    local actual
    actual="$(readlink "$target")"
    if [[ "$actual" == "$source" ]]; then
      log_line "PASS" "$target already links to expected source"
      return 0
    fi
    log_line "FAIL" "$target points to $actual instead of $source"
    return 1
  fi

  if [[ -f "$target" ]]; then
    log_line "FAIL" "$target is a regular file; refusing to overwrite"
    return 1
  fi

  if [[ -d "$target" ]]; then
    log_line "FAIL" "$target is a directory; refusing to replace it"
    return 1
  fi

  log_line "FAIL" "$target exists in unsupported state"
  return 1
}

run_explicit_mode() {
  local rc=0
  local entry

  for entry in "${MAP_ENTRIES[@]}"; do
    if ! process_explicit_entry "$entry"; then
      rc=1
    fi
  done

  return "$rc"
}

run_stow_mode() {
  if ! command -v stow >/dev/null 2>&1; then
    log_line "FAIL" "stow command not found"
    return 1
  fi

  if [[ ! -d "$REPO_ROOT/stow" ]]; then
    log_line "FAIL" "stow/ directory not found"
    return 1
  fi

  local existing=()
  local package
  for package in "${STOW_PACKAGES[@]}"; do
    if [[ -e "$REPO_ROOT/stow/$package" ]]; then
      existing+=("$package")
    fi
  done

  if [[ "${#existing[@]}" -eq 0 ]]; then
    log_line "FAIL" "no stow packages found under stow/"
    return 1
  fi

  case "$mode" in
    dry-run|status)
      stow --simulate --target="$HOME" --dir="$REPO_ROOT/stow" "${existing[@]}"
      ;;
    apply)
      stow --target="$HOME" --dir="$REPO_ROOT/stow" "${existing[@]}"
      ;;
  esac

  log_line "PASS" "stow mode completed for packages: ${existing[*]}"
}

while (($#)); do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --dry-run)
      mode="dry-run"
      ;;
    --apply)
      mode="apply"
      ;;
    --status)
      mode="status"
      ;;
    --stow)
      use_stow=true
      ;;
    *)
      log_line "FAIL" "unknown option: $1"
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if "$use_stow"; then
  run_stow_mode
else
  run_explicit_mode
fi
