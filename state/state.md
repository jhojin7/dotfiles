# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `open-terminal-here.sh` -> `macos/services/open-terminal-here.sh`, `docs/inventory.md`, `state/state.md`
- checks run: `git status --short`, `bash -n macos/services/open-terminal-here.sh`, `find macos -maxdepth 3 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
normalize-llm-punct-*.sh
rclone-init.sh
```

## Next safe step

Move the remaining approved root helper, then reassess the punctuation dedupe work separately.

Seven move tasks have been completed.
