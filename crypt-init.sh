#!/usr/bin/env bash
set -euo pipefail

KEY_FILE="${SOPS_AGE_KEY_FILE:-/var/lib/sops-nix/key.txt}"

usage() {
  cat <<'USAGE'
Usage: sudo ./crypt-init.sh

Initializes sops-nix age key on a new host.
Environment:
  SOPS_AGE_KEY_FILE  Override key path (default: /var/lib/sops-nix/key.txt)
USAGE
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root: sudo ./crypt-init.sh" >&2
  exit 1
fi

install -d -m 700 "$(dirname "$KEY_FILE")"

if [[ -f "$KEY_FILE" ]]; then
  echo "Key already exists: $KEY_FILE"
else
  nix shell nixpkgs#age -c age-keygen -o "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  echo "Created key: $KEY_FILE"
fi

recipient="$(nix shell nixpkgs#age -c age-keygen -y "$KEY_FILE")"

echo
echo "Age recipient:"
echo "$recipient"
echo
echo "Set this value in .sops.yaml (creation_rules[].age)."
