# dotfiles

Public-safe workstation config, setup notes, agent workflow rules, and small helper tools.

This branch is focused on turning the repo into a clean, agent-runnable dotfiles workspace that can be inspected, dry-run, and gradually migrated without leaking private machine state.

## Scope

- shell, editor, terminal, and AI tool config
- macOS, Linux, Raspberry Pi, and self-hosting notes
- Docker and Tailscale setup guidance
- small repo-local helper scripts
- autonomous cleanup state for repeatable agent loops

## Principles

- public-safe by default
- dry-run before apply
- no silent overwrites
- no private credentials or generated auth state
- small, auditable changes

## Repo map

- `docs/`: architecture, bootstrap, security, and platform notes
- `state/`: current loop plan, state, decisions, and notes
- `config/`: canonical public-safe config sources
- `stow/`: GNU Stow packages for managed dotfiles
- `packages/`: Homebrew, npm, uv, mas, and VS Code extension inventories
- `scripts/`: repo helper scripts such as `link.sh` and `doctor.sh`
- `macos/`, `linux/`, `raspberry-pi/`: platform-specific setup and service notes
- `services/`: self-hosting and service glue
- `tools/`: personal tools and incubating CLIs
- `ai/`: AI-specific rules, prompts, and examples

## Start here

- [SPEC.md](/Users/hojinjang/dev/dotfiles/SPEC.md)
- [AGENTS.md](/Users/hojinjang/dev/dotfiles/AGENTS.md)
- [docs/architecture.md](/Users/hojinjang/dev/dotfiles/docs/architecture.md)
- [docs/bootstrap.md](/Users/hojinjang/dev/dotfiles/docs/bootstrap.md)
- [docs/security.md](/Users/hojinjang/dev/dotfiles/docs/security.md)
- [state/plan.md](/Users/hojinjang/dev/dotfiles/state/plan.md)
- [state/state.md](/Users/hojinjang/dev/dotfiles/state/state.md)

## Current helpers

```sh
./scripts/doctor.sh --status
./scripts/link.sh --dry-run
```

`doctor.sh` is read-only. `link.sh` defaults to dry-run and refuses to overwrite regular files or directories.

## Status

The root cleanup pass is complete on `spring-cleanup`. Remaining warnings are mostly migration-related: canonical `config/` and `stow/` layouts are not fully seeded yet, and local home-directory config files intentionally block unsafe relinking until that migration is ready.
