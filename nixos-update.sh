#!/usr/bin/env bash
set -euo pipefail

HOST="tsunami"
HM_USER="kira"
DO_FLAKE_UPDATE=1
DO_HOME_MANAGER=1

usage() {
  cat <<'EOF'
Usage: ./nixos-update.sh [options]

Options:
  --host <name>          NixOS host in flake (default: tsunami)
  --user <name>          Home Manager user (default: kira)
  --no-flake-update      Skip `nix flake update`
  --no-home-manager      Skip `home-manager switch`
  -h, --help             Show this help

Examples:
  ./nixos-update.sh
  ./nixos-update.sh --host tsunami --user kira
  ./nixos-update.sh --no-flake-update
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="$2"
      shift 2
      ;;
    --user)
      HM_USER="$2"
      shift 2
      ;;
    --no-flake-update)
      DO_FLAKE_UPDATE=0
      shift
      ;;
    --no-home-manager)
      DO_HOME_MANAGER=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if [[ "${DO_FLAKE_UPDATE}" -eq 1 ]]; then
  echo "[1/3] Updating flake.lock..."
  nix --extra-experimental-features "nix-command flakes" flake update
else
  echo "[1/3] Skipping flake update."
fi

echo "[2/3] Rebuilding NixOS for host '${HOST}'..."
NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake ".#${HOST}"

if [[ "${DO_HOME_MANAGER}" -eq 1 ]]; then
  echo "[3/3] Applying Home Manager for user '${HM_USER}'..."
  if command -v home-manager >/dev/null 2>&1; then
    sudo -u "${HM_USER}" NIX_CONFIG="experimental-features = nix-command flakes" \
      home-manager switch --flake "${SCRIPT_DIR}#${HM_USER}"
  else
    echo "home-manager command not found, skipping."
  fi
else
  echo "[3/3] Skipping Home Manager."
fi

echo "Update completed."
