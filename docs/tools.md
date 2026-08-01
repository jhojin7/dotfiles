# Tools

## Scope

This repo can store small personal tools and helper scripts, but cleanup should separate them by role.

## Categories

- `scripts/`: repo management and machine bootstrap helpers
- `tools/bin/`: stable personal CLIs that are safe to keep in this repo
- `tools/incubator/`: larger or experimental tools that may later move to dedicated repos

## Rules

- default behavior must be read-only or dry-run
- repeated `--apply` runs must converge
- tools must not assume private credentials
- tools must not mutate outside the repo unless clearly documented and gated

## Current migration targets

- `data-telescope.sh` likely belongs under `tools/incubator/`
- `normalize-llm-punct-*.sh` should converge into one canonical tool
- one-off setup scripts should move into `scripts/` or `services/` only after review

## `tools/bin/git-repo-radar`

Safe local git repository status radar for macOS/Linux workstations.

```sh
./tools/bin/git-repo-radar
./tools/bin/git-repo-radar ~/dev ~/Documents/GitHub
./tools/bin/git-repo-radar --run ~/dev
```

Default roots are existing directories among `~/dev`, `~/src`, `~/repos`, `~/git`, `~/Projects`, `~/Documents/GitHub`, and `~/workspace`. The tool discovers normal `.git` directories plus `.git` files used by worktrees/submodules, skips heavy directories, runs `git fetch --all --prune --quiet` with prompts disabled, then reports only repos with behind/ahead/dirty/untracked/fetch-fail attention.

Default behavior is read-only after fetch/status. `--run`, `--execute`, and `--apply` additionally run `git pull --ff-only --quiet` only for repos that are behind, not ahead, and have no dirty or untracked working-tree entries. Repos with local changes, untracked files, ahead/diverged state, fetch failures, or status failures are reported and skipped.

Safety rule: it never runs non-fast-forward pull, merge, rebase, stash pop, or pull in dirty/untracked working trees.
