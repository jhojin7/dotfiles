# Bootstrap

## Policy

Bootstrap must be dry-run first and idempotent.

Required modes:

```sh
--help
--dry-run
--apply
--status
```

## macOS priority

1. Homebrew
2. `uv` and npm global tools
3. `mas`

## macOS first pass

```sh
brew bundle check --file packages/Brewfile
brew bundle install --file packages/Brewfile
```

On macOS, `packages/Brewfile` now includes Homebrew `bash`.
After install, keep the login shell aligned manually if desired:

```sh
brew --prefix bash
chsh -s "$(brew --prefix)/bin/bash"
```

If `$(brew --prefix)/bin/bash` is not already listed in `/etc/shells`, add it manually before using `chsh`.

System update settings are documented separately in `docs/macos.md`:

`System Settings > General > Software Update > Automatic Updates (i)`

Default script must only print this unless `--apply`.

## Docker

macOS uses Docker Desktop.

Checks:

```sh
docker --version
docker compose version
```

Do not auto-login to Docker Hub.

Do not write `~/.docker/config.json`.

## Tailscale

Checks:

```sh
tailscale version
tailscale status
```

Do not run `tailscale up` automatically.

Do not write auth keys.

## Linux/Raspberry Pi

Keep package install separate from service startup.

Docker/Tailscale login and service auth remain manual.
