#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mode="dry-run"
Brewfile="$REPO_ROOT/packages/Brewfile"

usage() {
  cat <<'EOF'
scripts/bootstrap-macos.sh

Bootstrap macOS with Homebrew-first package install and shell runtime checks.

Usage:
  ./scripts/bootstrap-macos.sh --dry-run
  ./scripts/bootstrap-macos.sh --status
  ./scripts/bootstrap-macos.sh --apply
  ./scripts/bootstrap-macos.sh --help

Notes:
  - Default mode is --dry-run.
  - The script installs Homebrew packages via Brewfile when --apply is used.
  - The script does not change the login shell automatically; it only checks
    the Homebrew bash setup and prints the manual chsh reminder.
EOF
}

log_line() {
  local level="$1"
  shift
  printf '%s %s\n' "$level" "$*"
}

trim_first_line() {
  printf '%s' "$1" | sed -n '1p'
}

check_repo_root() {
  if [[ -f "$REPO_ROOT/SPEC.md" && -f "$REPO_ROOT/AGENTS.md" && -d "$REPO_ROOT/state" ]]; then
    log_line "PASS" "repo root detected at $REPO_ROOT"
  else
    log_line "FAIL" "repo root markers missing under $REPO_ROOT"
    return 1
  fi
}

check_mode_commands() {
  if command -v bash >/dev/null 2>&1; then
    log_line "PASS" "command available: bash"
  else
    log_line "FAIL" "command missing: bash"
    return 1
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
      log_line "PASS" "command available: brew"
    else
      log_line "FAIL" "command missing: brew"
      return 1
    fi
  else
    log_line "WARN" "brew check skipped outside macOS"
  fi
}

check_brewfile_policy() {
  if grep -Fxq 'brew "bash"' "$Brewfile"; then
    log_line "PASS" "Brewfile includes brew \"bash\""
  else
    log_line "FAIL" "Brewfile is missing brew \"bash\""
    return 1
  fi
}

check_brew_bundle() {
  if ! command -v brew >/dev/null 2>&1; then
    log_line "WARN" "brew bundle check skipped because brew is unavailable"
    return 0
  fi

  if brew bundle check --file "$Brewfile" >/dev/null 2>&1; then
    log_line "PASS" "brew bundle check passed for packages/Brewfile"
    return 0
  fi

  case "$mode" in
    dry-run|status)
      log_line "WARN" "brew bundle check failed; run 'brew bundle install --file packages/Brewfile'"
      ;;
    apply)
      log_line "WARN" "brew bundle check failed; installing packages from Brewfile"
      brew bundle install --file "$Brewfile"
      log_line "PASS" "brew bundle install completed"
      ;;
  esac
}

check_homebrew_bash_shell() {
  local prefix bash_path current_shell

  if ! command -v brew >/dev/null 2>&1; then
    log_line "WARN" "Homebrew bash shell checks skipped because brew is unavailable"
    return 0
  fi

  prefix="$(brew --prefix bash 2>/dev/null || true)"
  if [[ -z "$prefix" ]]; then
    log_line "WARN" "Homebrew bash is not installed yet"
    return 0
  fi

  bash_path="$prefix/bin/bash"
  log_line "PASS" "Homebrew bash path: $bash_path"

  if grep -Fxq "$bash_path" /etc/shells 2>/dev/null; then
    log_line "PASS" "/etc/shells includes $bash_path"
  else
    log_line "WARN" "$bash_path is missing from /etc/shells; add it with sudo if you want to use it as a login shell"
  fi

  current_shell="${SHELL:-}"
  if [[ -z "$current_shell" ]]; then
    log_line "WARN" "SHELL environment variable is unset"
  elif [[ "$current_shell" == "$bash_path" ]]; then
    log_line "PASS" "current login shell points to Homebrew bash"
  else
    log_line "WARN" "current shell is $current_shell; switch with: chsh -s \"$bash_path\""
  fi
}

check_automatic_updates_note() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_line "WARN" "automatic update settings are macOS-specific; skipped"
    return 0
  fi

  log_line "PASS" "manual review path: System Settings > General > Software Update > Automatic Updates (i)"
  log_line "PASS" "keep 'Install Security Responses and system files' enabled and disable the other automatic options if you want lighter updates"
}

while (($#)); do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --dry-run|--status)
      mode="dry-run"
      ;;
    --apply)
      mode="apply"
      ;;
    *)
      log_line "FAIL" "unknown option: $1"
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  log_line "WARN" "macOS bootstrap is running on $(uname -s); continuing with read-only checks"
fi

check_repo_root
check_mode_commands
check_brewfile_policy
check_brew_bundle
check_homebrew_bash_shell
check_automatic_updates_note
