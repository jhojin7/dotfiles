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

## Guardrails

- do not commit private app state
- do not automate login flows
- keep service helpers idempotent where relevant
- document optional tools separately from default install
