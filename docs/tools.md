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
