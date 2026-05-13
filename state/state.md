# State

## Last loop

- timestamp: 2026-05-13
- branch: spring-cleanup
- files changed: docs/architecture.md, docs/tools.md, docs/ai.md, docs/macos.md, docs/linux.md, docs/raspberry-pi.md, docs/migration-log.md
- checks run: `git status --short`, `find . -maxdepth 3 -type f | sort`, `grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet)' docs state SPEC.md AGENTS.md`
- checks failed: none; secret scan returned policy-text false positives only and no likely credential values

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

Update `.gitignore` for secrets, Docker state, and Tailscale state.

No file moves yet.
