# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: `open-in-vscode.sh` -> `macos/services/open-in-vscode.sh`, `docs/inventory.md`, `state/state.md`, `state/notes.md`
- checks run: `git status --short`, `bash -n macos/services/open-in-vscode.sh`, `find macos -maxdepth 3 -type f | sort`
- checks failed: none

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
data-telescope.sh
normalize-llm-punct-*.sh
open-terminal-here.sh
hermes-agent/
setup.sh
dev_config.sh
startup.sh
rclone-init.sh
```

## Next safe step

Move another root script into its target folder, starting with a reviewed macOS or service helper.

One root script has been moved.
