# State

## Last loop

- timestamp: 2026-08-02
- branch: feat/git-repo-radar
- files changed: added explicit `--run`/`--execute`/`--apply` mode to `tools/bin/git-repo-radar` and documented pull behavior in `docs/tools.md`
- checks run: `bash -n tools/bin/git-repo-radar`, `./tools/bin/git-repo-radar --help`, `./tools/bin/git-repo-radar --dry-run .`, local fixture test for clean behind repo pulled by `--run`, local fixture test for dirty behind repo skipped by `--execute`, `git diff --check`, targeted secret scan on changed files
- checks failed: none

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
