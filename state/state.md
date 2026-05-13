# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: .gitignore
- checks run: `git status --short`, `git check-ignore -v oauth-client.json .docker/config.json .config/tailscale/state.conf id_ecdsa sample/tailscale/node.state`, `grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet)' .`
- checks failed: none; ignore patterns matched expected sample paths and secret scan returned false positives in policy docs, sample git hooks, and code identifiers only

## Current repo shape

Root still contains mixed scripts/configs.

Known root cleanup targets:

```text
data-telescope.sh
normalize-llm-punct-*.sh
open-in-vscode.sh
open-terminal-here.sh
hermes-agent/
setup.sh
dev_config.sh
startup.sh
rclone-init.sh
```

## Next safe step

Move one root script into its target folder with `git mv`.

No file moves yet.
