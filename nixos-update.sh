#!/usr/bin/env bash
set -euo pipefail

HOST="tsunami"
HM_USER="kira"
DO_FLAKE_UPDATE=0
DO_HOME_MANAGER=1

usage() {
  cat <<'EOF'
Usage: ./nixos-update.sh [options]

Options:
  --host <name>          NixOS host in flake (default: tsunami)
  --user <name>          Home Manager user (default: kira)
  -u, --update           Run `nix flake update` before rebuild
  --no-home-manager      Skip `home-manager switch`
  -h, --help             Show this help
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
    -u|--update)
      DO_FLAKE_UPDATE=1
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

# Проверка наличия nix
if ! command -v nix >/dev/null 2>&1; then
  echo "Warning: 'nix' command not found. Skipping flake update and rebuild steps."
  DO_FLAKE_UPDATE=0
  HAS_NIXOS_REBUILD=0
else
  HAS_NIXOS_REBUILD=1
fi

# Флейк апдейт
if [[ "${DO_FLAKE_UPDATE}" -eq 1 ]]; then
  echo "[1/3] Updating flake.lock..."
  nix --extra-experimental-features "nix-command flakes" flake update
else
  echo "[1/3] Skipping flake update."
fi

# NixOS rebuild
if [[ "${HAS_NIXOS_REBUILD}" -eq 1 ]]; then
  if command -v nixos-rebuild >/dev/null 2>&1; then
    echo "[2/3] Rebuilding NixOS for host '${HOST}'..."
    NIX_CONFIG="experimental-features = nix-command flakes" \
      nixos-rebuild switch --flake ".#${HOST}"
  else
    echo "[2/3] 'nixos-rebuild' not found, skipping NixOS rebuild."
  fi
else
  echo "[2/3] Skipping NixOS rebuild."
fi

# Home Manager
if [[ "${DO_HOME_MANAGER}" -eq 1 ]]; then
  echo "[3/3] Applying Home Manager for user '${HM_USER}'..."
  
  # Попытка найти home-manager
  HM_CMD="$(command -v home-manager || echo "/nix/var/nix/profiles/default/bin/home-manager")"
  
  if [[ -x "${HM_CMD}" ]]; then
    "${HM_CMD}" switch --flake "${SCRIPT_DIR}#${HM_USER}" -b "backup"
  else
    echo "home-manager command not found, skipping."
  fi
else
  echo "[3/3] Skipping Home Manager."
fi

echo "Update completed."
