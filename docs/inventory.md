# Inventory

Status: Seeded
Branch: `spring-cleanup`

## Current root files/dirs to classify

| Path | Type | Current role | Decision | Target path | Notes |
|---|---|---|---|---|---|
| `README.md` | docs | repo landing page | rewritten | `README.md` | concise public-safe overview and entry points |
| `config/zsh/zshrc` | config | shell config | moved/reviewed | `config/zsh/zshrc`, `stow/zsh/.zshrc` | seeded from current macOS config; public-safe review complete |
| `config/profile/profile` | config | shell profile | moved/reviewed | `config/profile/profile`, `stow/profile/.profile` | portable Linux keyboard guard added |
| `scripts/link.sh` | script | explicit link manager | moved | `scripts/link.sh` | replaces root `links.sh`; dry-run default with legacy source fallback until config migration |
| `scripts/doctor.sh` | script | read-only repo and machine health check | added | `scripts/doctor.sh` | reports PASS/WARN/FAIL with non-zero exit only for repo-level FAIL findings |
| `legacy/setup.sh` | script | old setup | moved | `legacy/setup.sh` then `scripts/bootstrap-*` | moved from repo root; no direct trust |
| `legacy/dev_config.sh` | script | dev package setup | moved | `legacy/dev_config.sh`, `packages/*` | moved from repo root; package inventory remains in `packages/` |
| `legacy/startup.sh` | script | old startup | moved | `legacy/startup.sh` | moved from repo root; keep until reviewed |
| `services/rclone/rclone-init.sh` | service/script | rclone setup | moved | `services/rclone/` | moved from repo root; never commit `rclone.conf` or assume auth in automation |
| `linux/gnome/` | linux | GNOME/desktop | moved | `linux/gnome/` | Linux-specific snippets still need dry-run/apply guards |
| `linux/nixos/` | linux | NixOS config | moved | `linux/nixos/` | no Home Manager dotfiles |
| `config/ghostty/` | config | terminal config | moved/reviewed | `config/ghostty/`, `stow/ghostty/` | macOS terminal |
| `config/kitty/` | config | terminal config | moved/reviewed | `config/kitty/`, `stow/kitty/` | terminal config |
| `config/nvim/` | config | editor config | moved/reviewed | `config/nvim/`, `stow/nvim/` | current local config; older lazy.nvim draft moved to `legacy/` |
| `config/tmux/` | config | tmux config | moved/reviewed | `config/tmux/`, `stow/tmux/` | current local config |
| `config/opencode/` | config | AI tool config | moved/reviewed | `config/opencode/`, `stow/opencode/` | remote Notion MCP kept disabled by default |
| `config/vscode/` | config | VS Code user settings | added/reviewed | `config/vscode/` | tracked as inventory; not linked automatically yet |
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
packages/vscode-extensions.txt
```
