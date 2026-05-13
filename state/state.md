# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `data-telescope.sh` -> `tools/incubator/data-telescope/data-telescope.sh`, `docs/inventory.md`, `state/state.md`
- checks run: `git status --short`, `bash -n tools/incubator/data-telescope/data-telescope.sh`, `find tools -maxdepth 4 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
normalize-llm-punct-*.sh
open-terminal-here.sh
rclone-init.sh
```

## Next safe step

Review the remaining root scripts individually before moving more. `open-terminal-here.sh` includes a permanent-delete workflow and `rclone-init.sh` assumes authenticated OneDrive mounts.

Six move tasks have been completed.
