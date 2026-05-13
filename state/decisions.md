# Decisions

## DEC-001: Use both link.sh and Stow

Decision:
Use both `scripts/link.sh` and GNU Stow.

Reason:
`link.sh` is explicit and auditable. Stow is conventional and useful for dotfile layout.

Consequence:
Both paths need validation.

## DEC-002: Do not use Nix/Home Manager as dotfile manager

Decision:
Do not use Nix/Home Manager for dotfiles.

Reason:
Current desired path is custom script + Stow.

Consequence:
NixOS config can stay, but dotfile linking remains outside Nix.

## DEC-003: Homebrew first on macOS

Decision:
macOS package priority is Homebrew, then `uv`/npm, then `mas`.

Reason:
Homebrew is most scriptable and portable for this repo.

## DEC-004: Exclude Karabiner, Hammerspoon, zoxide from default Brewfile

Decision:
Default Brewfile excludes `karabiner-elements`, `hammerspoon`, and `zoxide`.

Reason:
Not needed in default bootstrap.

## DEC-005: Docker is first-class

Decision:
Track Docker Desktop, Docker CLI, and Docker Compose v2 setup/checks.

Reason:
Docker is central to self-hosting/dev workflows.

Consequence:
Add `docs/docker.md`, Docker checks in `doctor.sh`, and Docker Desktop notes.

## DEC-006: Tailscale is first-class but auth stays manual

Decision:
Track Tailscale install/check docs. Do not automate login.

Reason:
Tailscale is important for Pi/self-hosting access, but auth keys/state must not be committed.

## DEC-007: Private case studies stay outside repo

Decision:
No private/redacted case-study docs in this repo.

Reason:
Out of scope for dotfiles.
