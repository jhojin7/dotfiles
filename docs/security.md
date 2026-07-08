# Security Policy

## Never commit

- API keys
- OAuth tokens
- cookies
- browser sessions
- SSH private keys
- `.env`
- Docker registry auth
- `~/.docker/config.json` with auth
- Tailscale auth keys
- Tailscale generated state
- rclone config
- private work/client docs

## Allowed

- public aliases
- public editor config
- public terminal config
- public package lists
- public agent rules/prompts/skills
- redacted example configs
- `.env.example`
- compose templates without secrets

## Required scan

```sh
grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet|registry token)' .
```

False positives must be reviewed manually.

## Docker-specific

Never commit:

```text
~/.docker/config.json
.docker/config.json
docker registry tokens
private `.env`
container data volumes
```

Track only:

```text
compose.yaml
.env.example
README.md
backup/restore notes
```

## Tailscale-specific

Never commit:

```text
auth keys
machine keys
tailscaled.state
tailnet-private identifiers
MagicDNS private hostnames unless intentionally public
```

Track only:

```text
install docs
safe status commands
manual auth steps
access architecture
```
