# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `hermes-agent/run-copyparty-artifacts.sh` -> `services/hermes-agent/run-copyparty-artifacts.sh`, `docs/inventory.md`, `state/state.md`
- checks run: `git status --short`, `bash -n services/hermes-agent/run-copyparty-artifacts.sh`, `find services -maxdepth 3 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
data-telescope.sh
normalize-llm-punct-*.sh
open-terminal-here.sh
setup.sh
dev_config.sh
startup.sh
rclone-init.sh
```

## Next safe step

Move another root script into its target folder, starting with a reviewed macOS or service helper.

Two move tasks have been completed.
