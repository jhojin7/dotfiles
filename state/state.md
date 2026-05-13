# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `rclone-init.sh` -> `services/rclone/rclone-init.sh`, `docs/inventory.md`, `state/state.md`
- checks run: `git status --short`, `bash -n services/rclone/rclone-init.sh`, `find services -maxdepth 3 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
normalize-llm-punct-*.sh
```

## Next safe step

Reassess the remaining root scripts. Only the punctuation-normalizer duplicates remain in root, so the next bounded task is comparison and canonicalization rather than another mechanical move.

Eight move tasks have been completed.
