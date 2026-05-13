# Dotfiles Spring Cleanup SPEC

Status: Draft v4
Branch: `spring-cleanup`
Repo: `jhojin7/dotfiles`
Mode: agent-runnable spring-cleaning branch

## 0. Current correction

This SPEC supersedes prior v3 notes.

Important corrections:

- Brewfile must not include Karabiner-Elements, Hammerspoon, or zoxide by default.
- Phase 0 should not only say "create docs"; this repo should receive seeded Phase 0 docs now.
- Docker, Docker Compose, Docker Desktop, and Tailscale must be first-class setup areas.
- Docker Compose means modern `docker compose`, not legacy `docker-compose`, unless documenting legacy compatibility.
- Tailscale setup must never commit auth keys, machine keys, Tailnet identifiers unless intentionally public, or generated state.

## 1. Goal

Turn this branch into a clean, public-safe, agent-runnable dotfiles repository for workstation setup, shell/editor/terminal config, macOS/Linux/Raspberry Pi setup notes, AI-agent config, Docker/self-hosting workflows, Tailscale access notes, and small personal tools.

Primary outcome:

```text
dotfiles can be cloned, inspected, dry-run, linked, and bootstrapped safely.
```

Secondary outcome:

```text
a coding agent can run repeated cleanup loops without losing context, duplicating work, leaking secrets, or breaking machine setup.
```

## 2. Non-goals

Do not do these in this repo:

- Do not store private case-study docs.
- Do not store client/work material.
- Do not store API keys, tokens, cookies, OAuth files, SSH private keys, browser sessions, Docker registry tokens, Tailscale auth keys, or provider auth files.
- Do not use Nix/Home Manager as dotfile manager.
- Do not require MCP servers.
- Do not require `launchd`.
- Do not rewrite all tools into product-grade repos during this cleanup.
- Do not force macOS-only assumptions onto Linux/Raspberry Pi targets.
- Do not delete existing scripts before they are inventoried and replacement path is documented.
- Do not expose home network services publicly by default.
- Do not make Cloudflare/DNS/Tailscale control-plane changes from setup scripts.

## 3. Resolved decisions

### 3.1 Machine targets

Support all of these:

```text
macOS Sequoia
macOS Tahoe
Ubuntu
NixOS
Raspberry Pi
work laptop
```

Priority order for implementation:

1. macOS Sequoia/Tahoe
2. Ubuntu
3. Raspberry Pi
4. NixOS
5. work laptop adjustments

### 3.2 macOS package manager policy

Priority order:

1. Homebrew
2. `uv` and npm global tools
3. `mas`

Policy:

- Homebrew owns first-pass machine bootstrap.
- `uv` owns Python CLIs and Python dev tools.
- npm owns JavaScript CLIs only when no better Homebrew/uv route exists.
- `mas` is optional and third priority because App Store auth/state is less portable.

### 3.3 Brewfile exclusions

Do not include these in default `packages/Brewfile`:

```text
karabiner-elements
hammerspoon
zoxide
```

Reason:

- Not part of current default install set.
- Can remain documented as optional later if needed.
- No accidental install on work laptop.

### 3.4 Symlink manager policy

Use both:

```text
scripts/link.sh
GNU Stow
```

Policy:

- `scripts/link.sh` is explicit, audited, user-friendly, and branch-specific.
- GNU Stow provides conventional dotfile package layout.
- Stow must be optional, not the only path.
- No Nix/Home Manager for dotfile management.

### 3.5 AI config scope

Upload after public-safety review:

```text
opencode
Hermes
Claude Code
Codex
Cursor
```

Raycast is not an AI tool. Raycast belongs under macOS/config automation.

### 3.6 Private docs

Private case-study docs stay outside this repo.

No `docs/case-studies/` for this cleanup.

### 3.7 Docker policy

Docker is first-class.

Track:

```text
Docker Desktop on macOS
Docker CLI checks
Docker Compose v2 checks via `docker compose`
Docker context notes
self-hosting compose project conventions
Raspberry Pi Docker service notes
```

Do not track:

```text
Docker Desktop private app state
Docker registry credentials
~/.docker/config.json if it contains auths
container volumes
private compose env files
```

### 3.8 Tailscale policy

Tailscale is first-class for private network access.

Track:

```text
install notes
safe status/check commands
SSH/access assumptions
Raspberry Pi access notes
self-hosting access architecture
```

Do not track:

```text
auth keys
machine keys
tailnet private IDs
generated state
ACL policy unless intentionally public and reviewed
MagicDNS/private hostnames unless reviewed
```

## 4. Target top-level tree

Use this target shape:

```text
.
├── README.md
├── SPEC.md
├── AGENTS.md
├── .gitignore
├── docs/
│   ├── inventory.md
│   ├── architecture.md
│   ├── bootstrap.md
│   ├── security.md
│   ├── agent-loop.md
│   ├── tools.md
│   ├── ai.md
│   ├── macos.md
│   ├── linux.md
│   ├── raspberry-pi.md
│   ├── docker.md
│   ├── tailscale.md
│   └── migration-log.md
├── state/
│   ├── plan.md
│   ├── state.md
│   ├── notes.md
│   └── decisions.md
├── scripts/
│   ├── doctor.sh
│   ├── link.sh
│   ├── unlink.sh
│   ├── bootstrap-macos.sh
│   ├── bootstrap-ubuntu.sh
│   ├── bootstrap-raspberry-pi.sh
│   └── bootstrap-nixos.sh
├── packages/
│   ├── Brewfile
│   ├── apt.txt
│   ├── npm-global.txt
│   ├── uv-tools.txt
│   └── mas.txt
├── stow/
│   ├── zsh/.zshrc
│   ├── profile/.profile
│   ├── nvim/.config/nvim/
│   ├── tmux/.config/tmux/tmux.conf
│   ├── ghostty/.config/ghostty/config
│   ├── kitty/.config/kitty/kitty.conf
│   └── opencode/.config/opencode/opencode.json
├── config/
│   ├── zsh/
│   ├── profile/
│   ├── nvim/
│   ├── tmux/
│   ├── ghostty/
│   ├── kitty/
│   ├── opencode/
│   ├── claude-code/
│   ├── codex/
│   ├── cursor/
│   ├── hermes/
│   ├── raycast/
│   └── docker/
├── ai/
│   ├── README.md
│   ├── AGENTS.md
│   ├── rules/
│   ├── prompts/
│   ├── skills/
│   ├── schemas/
│   └── examples/
├── macos/
│   ├── README.md
│   ├── defaults.sh
│   ├── apps.md
│   ├── finder-sidebar.md
│   ├── keyboard.md
│   ├── window-management.md
│   ├── docker-desktop.md
│   ├── services/
│   │   ├── open-in-vscode.sh
│   │   └── open-terminal-here.sh
│   └── raycast/
├── linux/
│   ├── README.md
│   ├── docker.md
│   ├── gnome/
│   └── nixos/
├── raspberry-pi/
│   ├── README.md
│   ├── docker.md
│   ├── tailscale.md
│   └── services/
├── services/
│   ├── hermes-agent/
│   │   └── run-copyparty-artifacts.sh
│   ├── rclone/
│   └── compose/
│       ├── README.md
│       └── examples/
├── tools/
│   ├── README.md
│   ├── bin/
│   │   └── normalize-llm-punct
│   └── incubator/
│       └── data-telescope/
│           └── data-telescope.sh
└── legacy/
    ├── setup.sh
    ├── dev_config.sh
    ├── startup.sh
    └── raw-notes.md
```

## 5. Phase 0 deliverables

Phase 0 should create real seeded files, not empty placeholders.

Required first patch:

```text
SPEC.md
AGENTS.md
.gitignore
docs/inventory.md
docs/security.md
docs/bootstrap.md
docs/agent-loop.md
docs/docker.md
docs/tailscale.md
state/plan.md
state/state.md
state/decisions.md
packages/Brewfile
packages/uv-tools.txt
packages/npm-global.txt
packages/mas.txt
```

No file moves in Phase 0.

Reason:

```text
Guardrails first. Moves second.
```

## 6. File placement rules

| Current path | Target path | Decision |
|---|---|---|
| `README.md` | `README.md` | rewrite short landing page |
| `zshrc` | `stow/zsh/.zshrc` and/or `config/zsh/zshrc` | public-safe config |
| `profile` | `stow/profile/.profile` and/or `config/profile/profile` | public-safe config |
| `links.sh` | `scripts/link.sh` | rewrite completely |
| `setup.sh` | `legacy/setup.sh`, then `scripts/bootstrap-*.sh` | split/rewrite |
| `dev_config.sh` | `legacy/dev_config.sh`, then package lists | split/rewrite |
| `startup.sh` | `legacy/startup.sh` | archive unless actively used |
| `rclone-init.sh` | `services/rclone/` | only public-safe wrapper/docs |
| `desktop/` | `linux/gnome/` | Ubuntu/GNOME-specific |
| `gnome/` | `linux/gnome/` | GNOME-specific |
| `nixos/` | `linux/nixos/` | keep, but not dotfile manager |
| `ghostty/` | `stow/ghostty/.config/ghostty/` and/or `config/ghostty/` | terminal config |
| `kitty/` | `stow/kitty/.config/kitty/` and/or `config/kitty/` | terminal config |
| `nvim/` | `stow/nvim/.config/nvim/` and/or `config/nvim/` | editor config |
| `tmux/` | `stow/tmux/.config/tmux/` and/or `config/tmux/` | terminal multiplexer |
| `opencode/` | `stow/opencode/.config/opencode/` and/or `config/opencode/` | AI tool config after review |
| `hermes-agent/run-copyparty-artifacts.sh` | `services/hermes-agent/run-copyparty-artifacts.sh` | self-hosting/agent service glue |
| `ai/normalize-llm-punct.sh` | `tools/bin/normalize-llm-punct` | tool, not AI rule |
| `normalize-llm-punct-1.sh` | delete after selecting canonical version | duplicate |
| `normalize-llm-punct-2.sh` | delete after selecting canonical version | duplicate |
| `normalize-llm-punct-3.sh` | delete after selecting canonical version | duplicate |
| `data-telescope.sh` | `tools/incubator/data-telescope/data-telescope.sh` | incubating CLI; likely dedicated repo later |
| `open-in-vscode.sh` | `macos/services/open-in-vscode.sh` | macOS service |
| `open-terminal-here.sh` | `macos/services/open-terminal-here.sh` | macOS service |

## 7. Tool version-tracking policy

### 7.1 Keep in dotfiles

Keep tools in dotfiles only when they are:

- personal workstation glue
- path/layout-dependent
- small enough to audit quickly
- useful mainly as setup helpers
- not worth separate issue tracker/release process

Examples:

```text
tools/bin/normalize-llm-punct
macos/services/open-in-vscode.sh
macos/services/open-terminal-here.sh
scripts/doctor.sh
scripts/link.sh
scripts/bootstrap-macos.sh
```

### 7.2 Incubate in dotfiles

Use `tools/incubator/<name>/` for tools that are useful but not yet clean products.

Current incubator candidate:

```text
tools/incubator/data-telescope/
```

Every incubating tool needs:

```text
README.md
NOTES.md
promote-to-repo.md
```

### 7.3 Move to dedicated repo later

Move a tool to dedicated repo when two or more apply:

- needs own README
- needs tests
- has CLI flags/config schema
- has meaningful dependencies
- has screenshots/demo
- can be portfolio item
- useful outside this dotfiles repo
- likely to receive issues/releases

`data-telescope.sh` likely qualifies later. For this cleanup, move it to incubator first, not separate repo immediately.

## 8. Guaranteed idempotency contract

All setup/link/bootstrap scripts must be guaranteed-idempotent.

Definition:

```text
Repeated dry-run and repeated apply converge to same state.
```

Hard requirements:

- Default mode must be read-only or dry-run.
- `--apply` required for machine mutation.
- Script must support `--help`.
- Script must support `--dry-run`.
- Script must support `--status` or equivalent when relevant.
- Script must not append duplicate PATH lines.
- Script must not append duplicate shell snippets.
- Script must not reinstall packages in custom loops when package manager can no-op.
- Script must not overwrite regular files silently.
- Script must treat already-correct symlink as success.
- Script must detect wrong-target symlink as conflict.
- Script must backup before replacing anything, or fail with explicit conflict.
- Script must avoid destructive `rm -rf`.
- Script must print exact planned mutations before applying them.
- Running same script twice must produce no new diff unless source config changed.

Minimum shell header:

```sh
#!/usr/bin/env bash
set -euo pipefail
```

Suggested interface:

```sh
./scripts/doctor.sh
./scripts/link.sh --dry-run
./scripts/link.sh --apply
./scripts/link.sh --status
./scripts/link.sh --stow --dry-run
./scripts/link.sh --stow --apply
./scripts/bootstrap-macos.sh --dry-run
./scripts/bootstrap-macos.sh --apply
```

## 9. `scripts/link.sh` spec

### Purpose

Create and manage symlinks for config files.

### Modes

```sh
./scripts/link.sh --dry-run
./scripts/link.sh --apply
./scripts/link.sh --status
./scripts/link.sh --stow --dry-run
./scripts/link.sh --stow --apply
```

### Required link map

Initial explicit map:

```text
config/zsh/zshrc              -> ~/.zshrc
config/profile/profile        -> ~/.profile
config/nvim                   -> ~/.config/nvim
config/tmux/tmux.conf         -> ~/.config/tmux/tmux.conf
config/ghostty/config         -> ~/.config/ghostty/config
config/kitty/kitty.conf       -> ~/.config/kitty/kitty.conf
config/opencode/opencode.json -> ~/.config/opencode/opencode.json
```

### Conflict handling

| Existing target state | Behavior |
|---|---|
| missing | create symlink |
| symlink to expected source | no-op |
| symlink to wrong source | conflict |
| normal file | conflict unless backup explicitly enabled |
| directory | conflict unless exact expected directory symlink/layout |
| broken symlink | conflict with repair suggestion |

## 10. `scripts/doctor.sh` spec

### Purpose

Read-only repo/machine health check.

### Checks

- OS detection.
- shell detection.
- required command detection.
- repo root detection.
- branch name detection.
- secret scan.
- shell syntax checks.
- JSON validation.
- broken symlink detection.
- Stow simulation if Stow exists.
- Docker CLI presence.
- Docker Desktop state on macOS.
- Docker Compose v2 availability via `docker compose version`.
- Tailscale CLI presence.
- Tailscale status command availability without requiring auth.
- expected config source paths.
- existing conflicting target files.
- executable bit check for scripts.

### Required output

```text
PASS / WARN / FAIL lines
final summary
non-zero exit for FAIL
```

### Commands doctor should run or suggest

```sh
bash -n scripts/*.sh
bash -n macos/**/*.sh
bash -n services/**/*.sh
jq . config/opencode/opencode.json
docker --version
docker compose version
tailscale version
tailscale status
grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet)' .
stow --simulate --target="$HOME" --dir=stow zsh profile nvim tmux ghostty kitty opencode
```

`taiIscale status` may warn if not logged in. That is not necessarily failure.

## 11. Package/bootstrap spec

### Package lists

Create:

```text
packages/Brewfile
packages/apt.txt
packages/npm-global.txt
packages/uv-tools.txt
packages/mas.txt
```

### macOS bootstrap

`bootstrap-macos.sh` must use package-manager priority:

1. Homebrew
2. `uv`/npm
3. `mas`

Initial `packages/Brewfile` contents:

```ruby
tap "homebrew/bundle"

brew "git"
brew "gh"
brew "uv"
brew "jq"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "stow"
brew "neovim"
brew "tmux"

cask "ghostty"
cask "visual-studio-code"
cask "docker"
cask "tailscale-app"
cask "raycast"
```

Explicitly not included:

```ruby
# cask "karabiner-elements"
# cask "hammerspoon"
# brew "zoxide"
```

### Docker bootstrap

macOS:

- Docker Desktop install belongs in Homebrew Cask as `cask "docker"`.
- Bootstrap must not auto-login to Docker Hub.
- Bootstrap must not write private `~/.docker/config.json`.
- `doctor.sh` must verify `docker --version`.
- `doctor.sh` must verify `docker compose version`.
- Docker Desktop settings are mostly app/private state; document manual settings in `macos/docker-desktop.md`.

Linux/Raspberry Pi:

- Docker setup belongs in `linux/docker.md` and `raspberry-pi/docker.md`.
- Compose must be checked as `docker compose`, not assumed as `docker-compose`.
- User/group changes must be documented and require explicit `--apply`.
- Running containers must be managed by service-specific compose files, not generic bootstrap.

### Tailscale bootstrap

macOS:

- Tailscale install belongs in Brewfile as `cask "tailscale-app"` unless user later chooses official standalone manual installer.
- Bootstrap must not run `tailscale up`.
- Bootstrap must not write auth keys.
- `doctor.sh` may check `tailscale version`.
- `tailscale status` can be WARN if not logged in.

Linux/Raspberry Pi:

- Tailscale install docs belong in `docs/tailscale.md` and `raspberry-pi/tailscale.md`.
- Auth/login stays manual.
- SSH/access assumptions must be documented, not encoded as secrets.

### Linux/Ubuntu bootstrap

Use `apt.txt` for first pass.

Do not mix GNOME settings into general package install.

### Raspberry Pi bootstrap

Keep Pi-specific service setup separate from desktop Linux.

Use:

```text
raspberry-pi/README.md
raspberry-pi/docker.md
raspberry-pi/tailscale.md
raspberry-pi/services/
scripts/bootstrap-raspberry-pi.sh
```

### NixOS

Keep NixOS config, but do not make Nix or Home Manager manage dotfiles.

## 12. macOS spec

### Files

```text
macos/README.md
macos/defaults.sh
macos/apps.md
macos/finder-sidebar.md
macos/keyboard.md
macos/window-management.md
macos/docker-desktop.md
macos/services/open-in-vscode.sh
macos/services/open-terminal-here.sh
macos/raycast/
```

### Defaults script policy

`macos/defaults.sh` must:

- default to dry-run
- print commands
- separate Finder/Dock/global settings
- avoid destructive changes
- avoid blind `killall` unless `--apply`
- support Sequoia/Tahoe notes
- document tested macOS version

### Docker Desktop settings

`macos/docker-desktop.md` must document:

- install method
- Compose v2 check
- resource settings to review manually
- file sharing paths to review manually
- no committed Docker Hub login
- no committed Desktop private settings
- standard project path convention

### Finder sidebar policy

Do not automate Finder sidebar mutations first.

Create `macos/finder-sidebar.md` with:

- tested OS version
- backup command
- candidate tool notes
- manual restore steps
- known fragility
- no automatic deletion

### Raycast policy

Raycast config is macOS automation config, not AI config.

Place under one of:

```text
config/raycast/
macos/raycast/
```

Use redacted docs/examples if actual export includes account/device identifiers.

## 13. AI config spec

### Files

```text
ai/README.md
ai/AGENTS.md
ai/rules/coding-agent.md
ai/rules/research-agent.md
ai/rules/safety.md
ai/prompts/implementation-plan.md
ai/prompts/code-review.md
ai/prompts/research-brief.md
ai/skills/spec-writing/SKILL.md
ai/skills/repo-audit/SKILL.md
ai/schemas/agent-task.schema.json
ai/examples/
```

### AI config target paths

```text
config/opencode/
config/claude-code/
config/codex/
config/cursor/
config/hermes/
```

### Public safety

Allowed:

- model names
- provider names
- non-secret local command config
- keybindings
- UI settings
- prompt templates
- public agent rules
- schemas
- redacted examples

Forbidden:

- live tokens
- provider auth files
- OAuth refresh tokens
- cookies
- browser profiles
- account IDs when unnecessary
- private system prompts from paid products if not explicitly reusable
- private work/project paths

## 14. Services/self-hosting spec

### Hermes

Current:

```text
hermes-agent/run-copyparty-artifacts.sh
```

Target:

```text
services/hermes-agent/run-copyparty-artifacts.sh
services/hermes-agent/README.md
```

### Docker Compose services

Target:

```text
services/compose/
services/compose/examples/
```

Rules:

- Compose examples must use `.env.example`, not `.env`.
- Named volumes are allowed only when clearly documented.
- Bind mounts must avoid private absolute paths unless shown as examples.
- Every compose project needs:
  - `README.md`
  - `compose.yaml`
  - `.env.example`
  - backup/restore notes when stateful
- Do not auto-start services from dotfiles bootstrap.

### rclone

Current:

```text
rclone-init.sh
```

Target:

```text
services/rclone/
```

Policy:

- never commit `rclone.conf`
- include example config only
- document auth flow separately
- default to dry-run for sync/copy examples

## 15. Agent loop protocol

This branch should be runnable by agent loops without constant user prompting.

Create seeded files:

```text
state/plan.md
state/state.md
state/notes.md
state/decisions.md
docs/agent-loop.md
```

Each agent loop must:

1. Read `SPEC.md`.
2. Read `AGENTS.md`.
3. Read `state/plan.md`.
4. Read `state/state.md`.
5. Select one small task.
6. Make bounded changes.
7. Run relevant checks.
8. Update `state/state.md`.
9. Update `state/notes.md` only if useful.
10. Stop with exact summary.

Each loop must not:

- ask user for decisions already resolved here
- edit unrelated files
- silently delete files
- move secrets
- perform destructive local commands
- claim checks passed without running them

## 16. Migration phases

### Phase 0: seeded guardrails first

Create or rewrite:

```text
SPEC.md
AGENTS.md
.gitignore
docs/security.md
docs/inventory.md
docs/bootstrap.md
docs/agent-loop.md
docs/docker.md
docs/tailscale.md
state/plan.md
state/state.md
state/decisions.md
packages/Brewfile
packages/uv-tools.txt
packages/npm-global.txt
packages/mas.txt
```

No file moves yet.

Done when:

- public/private boundary exists
- inventory exists
- agent loop has state files
- Docker/Tailscale setup docs exist
- Brewfile reflects current install policy
- current branch has working spec

### Phase 1: root cleanup

Move root scripts to correct categories.

Tasks:

- Move `data-telescope.sh` to `tools/incubator/data-telescope/data-telescope.sh`.
- Move `open-in-vscode.sh` to `macos/services/open-in-vscode.sh`.
- Move `open-terminal-here.sh` to `macos/services/open-terminal-here.sh`.
- Move `hermes-agent/run-copyparty-artifacts.sh` to `services/hermes-agent/run-copyparty-artifacts.sh`.
- Move `rclone-init.sh` to `services/rclone/` or `legacy/`.
- Move `setup.sh`, `dev_config.sh`, `startup.sh` to `legacy/`.
- Do not delete duplicates yet; document them.

Done when root contains no random scripts except intentional root files.

### Phase 2: tool deduplication

Tasks:

- Compare `normalize-llm-punct-1.sh`, `normalize-llm-punct-2.sh`, `normalize-llm-punct-3.sh`, and `ai/normalize-llm-punct.sh`.
- Pick canonical version.
- Move canonical version to `tools/bin/normalize-llm-punct`.
- Add `tools/README.md`.
- Delete or archive duplicate versions.
- Remove executable scripts from `ai/` unless they are actual AI config helpers.

### Phase 3: config layout

Tasks:

- Create `config/`.
- Create `stow/`.
- Move/copy config files into both intended layouts or choose one source-of-truth with generated mirror.
- Add `scripts/link.sh`.
- Add Stow simulation support.
- Add `scripts/unlink.sh`.

### Phase 4: bootstrap

Tasks:

- Add package lists.
- Add idempotent `bootstrap-macos.sh`.
- Add idempotent `bootstrap-ubuntu.sh`.
- Add `bootstrap-raspberry-pi.sh`.
- Keep `bootstrap-nixos.sh` minimal or docs-only.
- Add Docker checks.
- Add Tailscale checks.

### Phase 5: AI/macOS docs

Tasks:

- Rewrite `ai/`.
- Add AI rules/prompts/skills/schemas.
- Move/sanitize AI tool configs.
- Add `macos/` docs and service docs.
- Add Raycast notes or configs.
- Add Docker Desktop notes.

### Phase 6: checks

Tasks:

- Implement `doctor.sh`.
- Run syntax checks.
- Run JSON checks.
- Run secret scan.
- Run Stow simulation.
- Run Docker/Compose checks.
- Run Tailscale checks.
- Run link dry-run twice and compare output.

## 17. Acceptance checks

### Required commands

```sh
git status --short
find . -maxdepth 3 -type f | sort
bash -n scripts/*.sh
bash -n macos/**/*.sh
bash -n services/**/*.sh
jq . config/opencode/opencode.json
docker --version
docker compose version
tailscale version
./scripts/doctor.sh
./scripts/link.sh --dry-run
./scripts/link.sh --dry-run > /tmp/link.1
./scripts/link.sh --dry-run > /tmp/link.2
diff -u /tmp/link.1 /tmp/link.2
stow --simulate --target="$HOME" --dir=stow zsh profile nvim tmux ghostty kitty opencode
grep -RInE '(api[_-]?key|token|secret|password|cookie|bearer|oauth|private_key|client_secret|authkey|tailnet|registry token)' .
```

### Required result

- root directory is clean and intentional
- no unreviewed secret-looking values
- no duplicate punctuation-normalizer scripts
- no root-level app/service scripts
- README is short
- `SPEC.md` is current
- `state/state.md` records latest loop
- link dry-run is repeatable
- bootstrap scripts default to dry-run
- Stow path is available
- custom `link.sh` path is available
- Docker/Compose expectations are documented
- Tailscale expectations are documented
- no auth material is tracked

## 18. Immediate next tasks for agent

Start here:

1. Add this `SPEC.md`.
2. Add seeded `AGENTS.md`.
3. Add seeded docs in `docs/`.
4. Add seeded state files in `state/`.
5. Add package inventory files in `packages/`.
6. Update `.gitignore`.
7. Run no destructive commands.
8. Commit docs-only guardrail patch.

Recommended first commit:

```sh
git checkout spring-cleanup
git add SPEC.md AGENTS.md docs state packages .gitignore
git commit -m "Add spring cleanup guardrails"
```

Second commit only after guardrails:

```sh
git mv data-telescope.sh tools/incubator/data-telescope/data-telescope.sh
git mv open-in-vscode.sh macos/services/open-in-vscode.sh
git mv open-terminal-here.sh macos/services/open-terminal-here.sh
git mv hermes-agent/run-copyparty-artifacts.sh services/hermes-agent/run-copyparty-artifacts.sh
```

## 19. Stop conditions

Agent must stop and report instead of continuing if:

- secret scan finds likely credential
- script would overwrite a regular file
- branch is not `spring-cleanup`
- command requires auth
- command would mutate outside repo without explicit `--apply`
- file move would delete history or duplicate canonical source
- generated diff becomes too broad for one loop
- Docker/Tailscale command asks for login/auth
- compose file requires private `.env`
