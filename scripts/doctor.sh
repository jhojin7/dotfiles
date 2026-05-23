#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mode="dry-run"

pass_count=0
warn_count=0
fail_count=0

CONFIG_PATHS=(
  "config/zsh/zshrc"
  "config/profile/profile"
  "config/nvim"
  "config/tmux/tmux.conf"
  "config/ghostty/config"
  "config/kitty/kitty.conf"
)

usage() {
  cat <<'EOF'
scripts/doctor.sh

Read-only repo and machine health checks.

Usage:
  ./scripts/doctor.sh
  ./scripts/doctor.sh --dry-run
  ./scripts/doctor.sh --status
  ./scripts/doctor.sh --apply
  ./scripts/doctor.sh --help

Notes:
  - doctor is always read-only
  - --apply behaves the same as --dry-run and exists only for interface consistency
EOF
}

pass() {
  pass_count=$((pass_count + 1))
  printf 'PASS %s\n' "$*"
}

warn() {
  warn_count=$((warn_count + 1))
  printf 'WARN %s\n' "$*"
}

fail() {
  fail_count=$((fail_count + 1))
  printf 'FAIL %s\n' "$*"
}

trim_first_line() {
  printf '%s' "$1" | sed -n '1p'
}

check_repo_root() {
  if [[ -f "$REPO_ROOT/SPEC.md" && -f "$REPO_ROOT/AGENTS.md" && -d "$REPO_ROOT/state" ]]; then
    pass "repo root detected at $REPO_ROOT"
  else
    fail "repo root markers missing under $REPO_ROOT"
  fi
}

check_branch() {
  local branch
  if ! branch="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null)"; then
    fail "unable to determine git branch"
    return
  fi

  if [[ "$branch" == "spring-cleanup" ]]; then
    pass "branch is spring-cleanup"
  else
    fail "branch is $branch (expected spring-cleanup)"
  fi
}

check_os_and_shell() {
  pass "os $(uname -s) $(uname -m)"
  if [[ -n "${SHELL:-}" ]]; then
    pass "shell ${SHELL}"
  else
    warn "shell environment variable is unset"
  fi
}

check_required_commands() {
  local cmd
  for cmd in bash git jq; do
    if command -v "$cmd" >/dev/null 2>&1; then
      pass "command available: $cmd"
    else
      fail "command missing: $cmd"
    fi
  done

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
      pass "command available: brew"
    else
      fail "command missing: brew"
    fi
  fi
}

check_shell_syntax() {
  local checked=0
  local file

  while IFS= read -r -d '' file; do
    checked=1
    if bash -n "$file"; then
      pass "shell syntax: ${file#$REPO_ROOT/}"
    else
      fail "shell syntax: ${file#$REPO_ROOT/}"
    fi
  done < <(find "$REPO_ROOT/scripts" "$REPO_ROOT/macos" "$REPO_ROOT/services" -type f -name '*.sh' -print0 2>/dev/null)

  if [[ "$checked" -eq 0 ]]; then
    warn "no shell scripts found under scripts/, macos/, or services/"
  fi
}

check_secret_scan() {
  local matches
  matches="$(
    grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet)' \
      "$REPO_ROOT" \
      --exclude-dir=.git \
      --exclude=SPEC.md \
      --exclude=AGENTS.md \
      --exclude=README.md \
      --exclude-dir=docs \
      --exclude-dir=state || true
  )"

  if [[ -z "$matches" ]]; then
    pass "secret scan found no non-doc matches"
    return
  fi

  local line
  local suspicious=0
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    case "$line" in
      *"/.gitignore:"*|*"/nixos/configuration.nix:"*|*"/tools/incubator/data-telescope/data-telescope.sh:"*|*"/scripts/doctor.sh:"*)
        warn "secret-scan false positive: ${line#$REPO_ROOT/}"
        ;;
      *)
        fail "secret-scan suspicious match: ${line#$REPO_ROOT/}"
        suspicious=1
        ;;
    esac
  done <<<"$matches"

  if [[ "$suspicious" -eq 0 ]]; then
    pass "secret scan reviewed with false positives only"
  fi
}

check_broken_symlinks() {
  local broken
  broken="$(find "$REPO_ROOT" -path "$REPO_ROOT/.git" -prune -o -type l ! -exec test -e {} \; -print)"

  if [[ -z "$broken" ]]; then
    pass "no broken symlinks in repo"
    return
  fi

  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    fail "broken symlink: ${line#$REPO_ROOT/}"
  done <<<"$broken"
}

check_stow_simulation() {
  if ! command -v stow >/dev/null 2>&1; then
    warn "stow command not found"
    return
  fi

  if [[ ! -d "$REPO_ROOT/stow" ]]; then
    warn "stow/ directory not present yet"
    return
  fi

  if stow --simulate --target="$HOME" --dir="$REPO_ROOT/stow" zsh profile nvim tmux ghostty kitty opencode >/dev/null 2>&1; then
    pass "stow simulation completed"
  else
    warn "stow simulation reported issues"
  fi
}

check_docker() {
  local output
  if output="$(docker --version 2>&1)"; then
    pass "$(trim_first_line "$output")"
  else
    warn "docker unavailable: $(trim_first_line "$output")"
  fi

  if output="$(docker compose version 2>&1)"; then
    pass "$(trim_first_line "$output")"
  else
    warn "docker compose unavailable: $(trim_first_line "$output")"
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ -d "/Applications/Docker.app" ]]; then
      pass "Docker Desktop app present"
    else
      warn "Docker Desktop app not found in /Applications"
    fi
  fi
}

check_tailscale() {
  local output
  if ! output="$(tailscale version 2>&1)"; then
    warn "tailscale unavailable: $(trim_first_line "$output")"
    return
  fi
  pass "$(trim_first_line "$output")"

  if output="$(tailscale status 2>&1)"; then
    pass "tailscale status command succeeded"
  else
    warn "tailscale status unavailable or unauthenticated: $(trim_first_line "$output")"
  fi
}

check_expected_config_sources() {
  local rel
  for rel in "${CONFIG_PATHS[@]}"; do
    if [[ -e "$REPO_ROOT/$rel" ]]; then
      pass "config source present: $rel"
    else
      warn "config source missing: $rel"
    fi
  done
}

check_macos_bash_runtime() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    pass "macOS bash runtime checks skipped on $(uname -s)"
    return
  fi

  if grep -Fxq 'brew "bash"' "$REPO_ROOT/packages/Brewfile"; then
    pass 'packages/Brewfile includes brew "bash"'
  else
    fail 'packages/Brewfile is missing brew "bash"'
  fi

  if ! command -v brew >/dev/null 2>&1; then
    fail "brew command missing; cannot verify Homebrew bash runtime"
    return
  fi

  local prefix bash_path current_shell
  prefix="$(brew --prefix bash 2>/dev/null || true)"
  if [[ -z "$prefix" ]]; then
    warn "Homebrew bash formula is not installed yet"
    return
  fi

  bash_path="$prefix/bin/bash"
  if [[ -x "$bash_path" ]]; then
    pass "Homebrew bash installed at $bash_path"
  else
    fail "expected Homebrew bash binary missing at $bash_path"
  fi

  if grep -Fxq "$bash_path" /etc/shells 2>/dev/null; then
    pass "/etc/shells contains $bash_path"
  else
    warn "$bash_path is missing from /etc/shells"
  fi

  current_shell="${SHELL:-}"
  if [[ -z "$current_shell" ]]; then
    warn "SHELL environment variable is unset"
  elif [[ "$current_shell" == "$bash_path" ]]; then
    pass "current shell points to Homebrew bash"
  else
    warn "current shell is $current_shell; expected $bash_path"
  fi
}

check_link_status() {
  if [[ ! -x "$REPO_ROOT/scripts/link.sh" ]]; then
    fail "scripts/link.sh is missing or not executable"
    return
  fi

  local output line severity rest
  output="$("$REPO_ROOT/scripts/link.sh" --status 2>&1 || true)"

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    severity="${line%% *}"
    rest="${line#* }"

    case "$severity" in
      PASS)
        pass "link status: $rest"
        ;;
      WARN)
        warn "link status: $rest"
        ;;
      FAIL)
        if [[ "$rest" == *"broken symlink"* ]]; then
          fail "link status: $rest"
        else
          warn "link status: $rest"
        fi
        ;;
      *)
        warn "link status: $line"
        ;;
    esac
  done <<<"$output"
}

check_executable_bits() {
  local missing=0
  local file
  while IFS= read -r -d '' file; do
    if [[ ! -x "$file" ]]; then
      warn "script not executable: ${file#$REPO_ROOT/}"
      missing=1
    fi
  done < <(find "$REPO_ROOT/scripts" "$REPO_ROOT/macos" "$REPO_ROOT/services" -type f -name '*.sh' -print0 2>/dev/null)

  if [[ "$missing" -eq 0 ]]; then
    pass "script executable bits look good"
  fi
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
      mode="dry-run"
      warn "--apply requested; doctor remains read-only"
      ;;
    *)
      printf 'FAIL unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

check_repo_root
check_branch
check_os_and_shell
check_required_commands
check_shell_syntax
check_secret_scan
check_broken_symlinks
check_macos_bash_runtime
check_stow_simulation
check_docker
check_tailscale
check_expected_config_sources
check_link_status
check_executable_bits

printf 'SUMMARY pass=%d warn=%d fail=%d mode=%s\n' "$pass_count" "$warn_count" "$fail_count" "$mode"

if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
