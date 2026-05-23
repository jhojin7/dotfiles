# macOS

## Scope

macOS is the first implementation target for this cleanup.

## Package policy

Priority order:

1. Homebrew
2. `uv` and npm global tools
3. `mas`

## First-class areas

- terminal and shell config
- editor config
- Finder and desktop helpers
- Docker Desktop notes
- Tailscale install and status checks

## Shell runtime

- Install Homebrew `bash` via `packages/Brewfile`.
- Use Homebrew bash as the login shell with `chsh -s "$(brew --prefix)/bin/bash"` after adding that path to `/etc/shells` if needed.
- Keep Apple’s `/bin/bash` untouched; do not try to overwrite the system binary.

## Automatic updates

Apple’s current path is:

`Apple menu > System Settings > General > Software Update > Automatic Updates (i)`

For a lighter auto-update posture, keep **Install Security Responses and system files** on and turn the other automatic install/download options off.

Notes:

- On older macOS versions, the label may read **Install system data files and security updates** instead.
- The user-facing menu path above is the right place to record in this repo.

## Guardrails

- do not commit private app state
- do not automate login flows
- keep service helpers idempotent where relevant
- document optional tools separately from default install
