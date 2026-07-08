# State

## Last loop

- timestamp: 2026-07-07
- branch: spring-cleanup
- files changed: seeded `config/`, `stow/`, Linux target folders, package inventories, VS Code settings, and docs on top of the macOS bootstrap/doctor updates
- checks run: `bash -n ...`, `jq empty`, `git diff --check`, `./scripts/doctor.sh --status`, `./scripts/bootstrap-macos.sh --dry-run`, `./scripts/link.sh --dry-run`, `brew bundle check --file packages/Brewfile --verbose`, direct secret grep
- checks failed: `./scripts/link.sh --dry-run` refused existing home config files as designed; `brew bundle check`/bootstrap reported pending installs or updates; Stow simulation skipped because `stow` is not installed on PATH

## Current repo shape

Managed dotfiles now live under `config/` with GNU Stow packages planned under `stow/`.
Kitty is legacy-only and is not part of active managed config.
Linux desktop and NixOS files live under `linux/`.
macOS bootstrap has a guarded `scripts/bootstrap-macos.sh` path.

Known root cleanup targets:

```text
none known
```

## Next safe step

Review whether to migrate existing home config files into symlinks, then install missing Brewfile dependencies and run Stow simulation.
