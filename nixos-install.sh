#!/usr/bin/env bash
set -euo pipefail

HOST="tsunami"
MNT="/mnt"
YES=0
DISKO_CONFIG=""

usage() {
  cat <<'EOF'
Usage: ./nixos-install.sh [options]

Options:
  --host <name>           NixOS host from flake (default: tsunami)
  --disko-config <path>   Path to disko config (default: by host)
  --mnt <path>            Target mount root (default: /mnt)
  --yes                   Skip destructive confirmation
  -h, --help              Show this help

Examples:
  ./nixos-install.sh
  ./nixos-install.sh --host tsunami --disko-config ./disko/vbox.nix
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="$2"
      shift 2
      ;;
    --disko-config)
      DISKO_CONFIG="$2"
      shift 2
      ;;
    --mnt)
      MNT="$2"
      shift 2
      ;;
    --yes)
      YES=1
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
HOST_DIR="${SCRIPT_DIR}/hosts/${HOST}"
HOST_CONFIG="${HOST_DIR}/configuration.nix"
HARDWARE_DEST="${HOST_DIR}/hardware-configuration.nix"
GEN_HARDWARE="${MNT}/etc/nixos/hardware-configuration.nix"

if [[ -z "${DISKO_CONFIG}" ]]; then
  case "${HOST}" in
    tsunami) DISKO_CONFIG="${SCRIPT_DIR}/disko/tsunami.nix" ;;
    vbox) DISKO_CONFIG="${SCRIPT_DIR}/disko/vbox.nix" ;;
    *) DISKO_CONFIG="${SCRIPT_DIR}/disko/${HOST}.nix" ;;
  esac
fi

if [[ "${DISKO_CONFIG}" != /* ]]; then
  DISKO_CONFIG="${SCRIPT_DIR}/${DISKO_CONFIG#./}"
fi

if [[ ! -f "${DISKO_CONFIG}" ]]; then
  echo "Disko config not found: ${DISKO_CONFIG}" >&2
  exit 1
fi

if [[ ! -f "${HOST_CONFIG}" ]]; then
  echo "Host config not found: ${HOST_CONFIG}" >&2
  exit 1
fi

for cmd in nix nixos-generate-config nixos-install; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Required command not found: ${cmd}" >&2
    exit 1
  fi
done

DEVICE="$(sed -n 's/^[[:space:]]*device[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "${DISKO_CONFIG}" | head -n1 || true)"
if [[ -z "${DEVICE}" ]]; then
  DEVICE="<unknown>"
fi

if [[ "${YES}" -ne 1 ]]; then
  echo "About to wipe disk using disko config:"
  echo "  host: ${HOST}"
  echo "  disko: ${DISKO_CONFIG}"
  echo "  device: ${DEVICE}"
  read -r -p "Continue? Type 'yes' to proceed: " answer
  if [[ "${answer}" != "yes" ]]; then
    echo "Aborted."
    exit 1
  fi
fi

echo "[1/4] Running disko..."
nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko "${DISKO_CONFIG}"

echo "[2/4] Generating hardware config..."
nixos-generate-config --root "${MNT}"
if [[ ! -f "${GEN_HARDWARE}" ]]; then
  echo "Generated hardware config not found: ${GEN_HARDWARE}" >&2
  exit 1
fi

echo "[3/4] Copying hardware config into repo..."
mkdir -p "${HOST_DIR}"
install -m 0644 "${GEN_HARDWARE}" "${HARDWARE_DEST}"

if ! grep -qF "./hardware-configuration.nix" "${HOST_CONFIG}"; then
  tmp_file="$(mktemp)"
  awk '
    {
      print
      if (!done && $0 ~ /imports[[:space:]]*=[[:space:]]*\[/) {
        print "    ./hardware-configuration.nix"
        done = 1
      }
    }
    END {
      if (!done) {
        exit 2
      }
    }
  ' "${HOST_CONFIG}" > "${tmp_file}" || {
    rm -f "${tmp_file}"
    echo "Failed to inject ./hardware-configuration.nix into ${HOST_CONFIG}" >&2
    exit 1
  }
  mv "${tmp_file}" "${HOST_CONFIG}"
fi

echo "[4/4] Installing NixOS from flake..."
nixos-install --flake "${SCRIPT_DIR}#${HOST}" --extra-experimental-features "nix-command flakes"

echo
echo "Install completed for host '${HOST}'."
echo "Next steps:"
echo "  1) Reboot: reboot"
echo "  2) Set user password (example): passwd kira"
