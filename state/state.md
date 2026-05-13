# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `setup.sh` -> `legacy/setup.sh`, `docs/inventory.md`, `state/state.md`
- checks run: `git status --short`, `bash -n legacy/setup.sh`, `find legacy -maxdepth 2 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
data-telescope.sh
normalize-llm-punct-*.sh
open-terminal-here.sh
dev_config.sh
rclone-init.sh
```

## Next safe step

Move another root script into its target folder, likely one of the remaining legacy-bound setup scripts.

Four move tasks have been completed.
