#!/usr/bin/env bash
set -euo pipefail

# Copyparty runner for Hermes published artifacts.
# Serves only ~/.hermes/artifacts/published as read-only.
# Default bind target: Tailscale IPv4 if available, otherwise 127.0.0.1.
#
# Usage:
#   ~/.hermes/scripts/run-copyparty-artifacts.sh start
#   ~/.hermes/scripts/run-copyparty-artifacts.sh url bloomberg-tech/2026-05-08.md
#   BIND=0.0.0.0 PORT=3923 ~/.hermes/scripts/run-copyparty-artifacts.sh restart
#
# Optional env:
#   BIND=100.x.y.z               bind address; default auto Tailscale IP or 127.0.0.1
#   PORT=3923                    host/container port
#   PUBLIC_BASE=http://host:3923  URL base used by the `url` command
#   IMAGE=copyparty/ac:latest     Docker image
#   ROOT=$HOME/.hermes/artifacts/published
#   NAME=hermes-copyparty-artifacts

ACTION="${1:-start}"
ARG="${2:-}"

HOME_DIR="${HOME:-/home/hojinjang}"
ROOT="${ROOT:-$HOME_DIR/.hermes/artifacts/published}"
STATE_DIR="${STATE_DIR:-$HOME_DIR/.hermes/state/copyparty-artifacts}"
CONFIG="$STATE_DIR/copyparty.conf"
IMAGE="${IMAGE:-copyparty/ac:latest}"
NAME="${NAME:-hermes-copyparty-artifacts}"
PORT="${PORT:-3923}"

if [[ -z "${BIND:-}" ]]; then
  if command -v tailscale >/dev/null 2>&1; then
    BIND="$(tailscale ip -4 2>/dev/null | head -n1 || true)"
  fi
  BIND="${BIND:-127.0.0.1}"
fi

if [[ -z "${PUBLIC_BASE:-}" ]]; then
  PUBLIC_BASE="http://${BIND}:${PORT}"
fi

need_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found" >&2
    exit 1
  fi
}

write_config() {
  mkdir -p "$ROOT" "$STATE_DIR"
  cat > "$CONFIG" <<'EOF'
# copyparty config for Hermes published artifacts
# Only /w is mounted into the container, read-only from Docker and read-only in copyparty ACL.

[global]
  p: 3923
  no-robots

[/]
  /w
  accs:
    r: *
EOF
}

start() {
  need_docker
  write_config

  if docker ps --format '{{.Names}}' | grep -Fxq "$NAME"; then
    echo "already running: $NAME"
    echo "base url: $PUBLIC_BASE"
    return 0
  fi

  if docker ps -a --format '{{.Names}}' | grep -Fxq "$NAME"; then
    docker rm "$NAME" >/dev/null
  fi

  docker pull "$IMAGE" >/dev/null
  docker run -d \
    --name "$NAME" \
    --restart unless-stopped \
    -p "${BIND}:${PORT}:3923" \
    -v "$ROOT:/w:ro" \
    -v "$CONFIG:/cfg/copyparty.conf:ro" \
    "$IMAGE" \
    -c /cfg/copyparty.conf >/dev/null

  echo "started: $NAME"
  echo "root: $ROOT"
  echo "base url: $PUBLIC_BASE"
  echo "md preview URLs should use: <url>.md?v"
}

stop() {
  need_docker
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  echo "stopped: $NAME"
}

status() {
  need_docker
  docker ps -a --filter "name=^/${NAME}$" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
}

logs() {
  need_docker
  docker logs -f --tail=120 "$NAME"
}

make_url() {
  local rel="$ARG"
  rel="${rel#$ROOT/}"
  rel="${rel#/}"
  if [[ -z "$rel" ]]; then
    echo "$PUBLIC_BASE/"
    return 0
  fi
  # URL-encode path-ish input while preserving slashes.
  python3 - "$PUBLIC_BASE" "$rel" <<'PY'
import sys, urllib.parse
base, rel = sys.argv[1].rstrip('/'), sys.argv[2]
enc = '/'.join(urllib.parse.quote(p) for p in rel.split('/'))
suffix = '?v' if enc.lower().endswith(('.md', '.markdown', '.txt', '.html', '.htm', '.pdf')) else ''
print(f'{base}/{enc}{suffix}')
PY
}

case "$ACTION" in
  start) start ;;
  stop) stop ;;
  restart) stop; start ;;
  status) status ;;
  logs) logs ;;
  url) make_url ;;
  config) write_config; echo "$CONFIG" ;;
  *)
    cat >&2 <<EOF
Usage: $0 {start|stop|restart|status|logs|url|config} [relative-file]

Examples:
  $0 start
  $0 url bloomberg-tech/2026-05-08.md
  BIND=0.0.0.0 PORT=3923 $0 restart
EOF
    exit 2
    ;;
esac
