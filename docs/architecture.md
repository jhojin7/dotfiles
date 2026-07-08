# Architecture

## Goal

Describe the stable shape of this repo after `spring-cleanup`.

## Top-level layout

- `docs/`: setup guides, architecture notes, migration log, and agent workflow docs
- `state/`: loop state for autonomous cleanup work
- `config/`: canonical config sources before linking or stow packaging
- `stow/`: GNU Stow packages for managed dotfiles
- `scripts/`: idempotent helper scripts with dry-run first behavior
- `macos/`: macOS-specific setup notes and service helpers
- `linux/`: Linux-specific setup notes and machine config
- `raspberry-pi/`: Raspberry Pi setup and service notes
- `services/`: self-hosting glue, compose projects, and service docs
- `tools/`: personal tools and incubating CLIs
- `ai/`: public-safe agent rules, prompts, schemas, and examples

## Principles

- public-safe by default
- idempotent scripts
- dry-run before apply
- no private machine state in version control
- small, auditable cleanup steps

## Pending work

- align root files with target folders from `docs/inventory.md`
- add a bootstrap and doctor path that matches `AGENTS.md`
- convert managed configs into `config/` plus `stow/` layout
- keep VS Code settings and extension inventory under review before enabling automatic linking
