# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `dev_config.sh` -> `legacy/dev_config.sh`, `docs/inventory.md`, `state/state.md`
- checks run: `git status --short`, `bash -n legacy/dev_config.sh`, `find legacy -maxdepth 2 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
data-telescope.sh
normalize-llm-punct-*.sh
open-terminal-here.sh
rclone-init.sh
```

## Next safe step

Review the remaining root scripts individually before moving more, because they now span tools, macOS actions, and service bootstrap helpers.

Five move tasks have been completed.
