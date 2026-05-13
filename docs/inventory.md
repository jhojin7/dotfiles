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
| `legacy/setup.sh` | script | old setup | moved | `legacy/setup.sh` then `scripts/bootstrap-*` | moved from repo root; no direct trust |
| `legacy/dev_config.sh` | script | dev package setup | moved | `legacy/dev_config.sh`, `packages/*` | moved from repo root; package inventory remains in `packages/` |
| `legacy/startup.sh` | script | old startup | moved | `legacy/startup.sh` | moved from repo root; keep until reviewed |
| `services/rclone/rclone-init.sh` | service/script | rclone setup | moved | `services/rclone/` | moved from repo root; never commit `rclone.conf` or assume auth in automation |
| `desktop/` | linux | GNOME/desktop | move | `linux/gnome/` | Linux-specific |
| `gnome/` | linux | GNOME helper | move | `linux/gnome/` | Linux-specific |
| `nixos/` | linux | NixOS config | move | `linux/nixos/` | no Home Manager dotfiles |
| `ghostty/` | config | terminal config | move | `config/ghostty/`, `stow/ghostty/` | macOS terminal |
| `kitty/` | config | terminal config | move | `config/kitty/`, `stow/kitty/` | terminal config |
| `nvim/` | config | editor config | move | `config/nvim/`, `stow/nvim/` | editor config |
| `tmux/` | config | tmux config | move | `config/tmux/`, `stow/tmux/` | tmux config |
| `opencode/` | config | AI tool config | review/move | `config/opencode/`, `stow/opencode/` | check secrets |
| `ai/` | rules/config | AI-specific content only | cleaned | `ai/` | utility script moved out; keep rules/prompts/skills/examples only |
| `services/hermes-agent/` | service | Hermes service glue | moved | `services/hermes-agent/` | moved from repo root |
| `tools/incubator/data-telescope/data-telescope.sh` | tool | large CLI | moved | `tools/incubator/data-telescope/` | moved from repo root; likely dedicated repo later |
| `tools/bin/normalize-llm-punct` | tool | canonical punctuation normalizer | moved | `tools/bin/normalize-llm-punct` | promoted from `ai/normalize-llm-punct.sh`; root duplicates removed |
| `macos/services/open-in-vscode.sh` | macOS service | Finder/service helper | moved | `macos/services/open-in-vscode.sh` | moved from repo root |
| `macos/services/open-terminal-here.sh` | macOS service | Finder/service helper | moved | `macos/services/open-terminal-here.sh` | moved from repo root; still bundles copy-path and permanent-delete actions |

## New first-class docs

Add:

```text
docs/docker.md
docs/tailscale.md
macos/docker-desktop.md
raspberry-pi/docker.md
raspberry-pi/tailscale.md
```
