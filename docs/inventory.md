# Inventory

Status: Seeded
Branch: `spring-cleanup`

## Current root files/dirs to classify

| Path | Type | Current role | Decision | Target path | Notes |
|---|---|---|---|---|---|
| `README.md` | docs | scratch/TODO | rewrite | `README.md` | short landing page |
| `zshrc` | config | shell config | move/review | `config/zsh/zshrc`, `stow/zsh/.zshrc` | public-safe review |
| `profile` | config | shell profile | move/review | `config/profile/profile`, `stow/profile/.profile` | public-safe review |
| `links.sh` | script | one-line symlink | rewrite | `scripts/link.sh` | idempotent required |
| `setup.sh` | script | old setup | archive/split | `legacy/setup.sh` then `scripts/bootstrap-*` | no direct trust |
| `dev_config.sh` | script | dev package setup | archive/split | `legacy/dev_config.sh`, `packages/*` | package inventory |
| `startup.sh` | script | old startup | archive | `legacy/startup.sh` | keep until reviewed |
| `rclone-init.sh` | service/script | rclone setup | move/review | `services/rclone/` | never commit `rclone.conf` |
| `desktop/` | linux | GNOME/desktop | move | `linux/gnome/` | Linux-specific |
| `gnome/` | linux | GNOME helper | move | `linux/gnome/` | Linux-specific |
| `nixos/` | linux | NixOS config | move | `linux/nixos/` | no Home Manager dotfiles |
| `ghostty/` | config | terminal config | move | `config/ghostty/`, `stow/ghostty/` | macOS terminal |
| `kitty/` | config | terminal config | move | `config/kitty/`, `stow/kitty/` | terminal config |
| `nvim/` | config | editor config | move | `config/nvim/`, `stow/nvim/` | editor config |
| `tmux/` | config | tmux config | move | `config/tmux/`, `stow/tmux/` | tmux config |
| `opencode/` | config | AI tool config | review/move | `config/opencode/`, `stow/opencode/` | check secrets |
| `ai/` | mixed | currently contains tool script | rewrite | `ai/` | rules/prompts/skills only |
| `hermes-agent/` | service | Hermes service glue | move | `services/hermes-agent/` | self-hosting |
| `data-telescope.sh` | tool | large CLI | incubate | `tools/incubator/data-telescope/` | likely dedicated repo later |
| `normalize-llm-punct-*.sh` | tool duplicates | utility versions | dedupe | `tools/bin/normalize-llm-punct` | choose canonical |
| `macos/services/open-in-vscode.sh` | macOS service | Finder/service helper | moved | `macos/services/open-in-vscode.sh` | moved from repo root |
| `open-terminal-here.sh` | macOS service | Finder/service helper | move | `macos/services/open-terminal-here.sh` | macOS-only |

## New first-class docs

Add:

```text
docs/docker.md
docs/tailscale.md
macos/docker-desktop.md
raspberry-pi/docker.md
raspberry-pi/tailscale.md
```
