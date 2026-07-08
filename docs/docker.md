# Docker

## Scope

Docker is first-class for this repo.

Track setup and checks for:

- Docker Desktop on macOS
- Docker CLI
- Docker Compose v2 via `docker compose`
- Raspberry Pi Docker setup
- service-specific compose projects

## macOS

Default install path:

```ruby
cask "docker"
```

Checks:

```sh
docker --version
docker compose version
docker context ls
```

Do not commit Docker Desktop private state.

Do not commit Docker Hub login state.

## Compose convention

Each compose project should contain:

```text
README.md
compose.yaml
.env.example
```

Rules:

- no `.env`
- no private hostnames unless reviewed
- no absolute personal paths unless documented as example only
- no auto-start from dotfiles bootstrap
- stateful services need backup/restore notes

## Current self-hosting context

Known future service docs may include:

- FreshRSS migration from Mac Docker to Raspberry Pi Docker
- Hermes/OpenClaw-related artifact service
- RSS bot/dashboard
- backup tooling

Cloudflare Tunnel is low priority and should not be assumed as default path.
