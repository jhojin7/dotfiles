# AGENTS.md

## Purpose

This repo stores public-safe workstation config, setup docs, AI-agent workflow rules, small helper tools, and self-hosting setup notes.

## Operating mode

This repo is edited in small, repeatable loops.

Before changing files:

1. Read `SPEC.md`.
2. Read this file.
3. Read `state/plan.md`.
4. Read `state/state.md`.
5. Pick one bounded task.
6. Make minimal changes.
7. Run relevant checks.
8. Update `state/state.md`.
9. Stop with exact summary.

## Hard rules

- Do not commit secrets.
- Do not commit tokens.
- Do not commit cookies.
- Do not commit SSH private keys.
- Do not commit OAuth files.
- Do not commit browser profiles.
- Do not commit Docker registry auth.
- Do not commit Tailscale auth keys or generated state.
- Do not commit private work/client docs.
- Do not run destructive commands without explicit `--apply`.
- Do not mutate files outside repo.
- Do not silently overwrite regular files.
- Do not claim checks passed unless actually run.
- Do not ask for decisions already resolved in `SPEC.md`.

## Idempotency rules

All scripts must be safe to run repeatedly.

Required script interface when relevant:

```sh
--help
--dry-run
--apply
--status
```

Default must be dry-run/read-only.

Repeated `--apply` must converge to same state.

## Tooling rules

- Use `scripts/link.sh` and GNU Stow support.
- Do not use Nix/Home Manager as dotfile manager.
- Keep Homebrew as macOS primary package manager.
- Use `uv` and npm after Homebrew.
- Use `mas` only for App Store inventory.
- Use `docker compose`, not legacy `docker-compose`, unless documenting compatibility.

## Folder rules

- `ai/`: rules, prompts, skills, schemas, examples.
- `tools/`: personal tools and incubating CLIs.
- `macos/`: macOS-specific setup/services/docs.
- `linux/`: Linux-specific setup/docs.
- `raspberry-pi/`: Pi-specific setup/docs.
- `services/`: self-hosting/service glue.
- `config/`: canonical config files.
- `stow/`: GNU Stow layout.
- `state/`: loop state for agents.

## Required checks

Run relevant subset:

```sh
git status --short
bash -n scripts/*.sh
bash -n macos/**/*.sh
bash -n services/**/*.sh
bash -n linux/**/*.sh
docker --version
docker compose version
tailscale version
./scripts/link.sh --dry-run
grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet)' .
```

## Stop conditions

Stop and report if:

- secret scan finds likely credential
- branch is neither `main` nor the expected task branch
- command needs login/auth
- action would overwrite a normal file
- diff becomes too broad
- Docker/Tailscale setup requires private account action
