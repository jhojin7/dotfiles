# Tailscale

## Scope

Tailscale is first-class for private access and Raspberry Pi/self-hosting.

Track:

- install notes
- check commands
- SSH/access assumptions
- Raspberry Pi access notes
- service access architecture

Do not track:

- auth keys
- machine keys
- generated state
- private tailnet identifiers
- private MagicDNS names unless reviewed

## macOS

Candidate Brewfile entry:

```ruby
cask "tailscale-app"
```

Checks:

```sh
tailscale version
tailscale status
```

`tailscale status` may warn if not logged in. That is not automatically failure.

## Raspberry Pi

Keep Pi-specific docs under:

```text
raspberry-pi/tailscale.md
```

No setup script should run `tailscale up` automatically.

## Architecture preference

Prefer private access through Tailscale for home/self-hosted services.

For uptime/status dashboard from outside home network, prefer outbound HTTPS heartbeat rather than exposing home network.
