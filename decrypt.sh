#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./decrypt.sh <input-file> [output-file]

Decrypt sops file via nix shell.
Environment:
  SOPS_AGE_KEY_FILE  Path to age key (default: /var/lib/sops-nix/key.txt)

Examples:
  ./decrypt.sh secrets/netbird.yaml
  ./decrypt.sh secrets/netbird.yaml /tmp/netbird.yaml
USAGE
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

input_file="$1"
if [[ ! -f "$input_file" ]]; then
  echo "Input file not found: $input_file" >&2
  exit 1
fi

key_file="${SOPS_AGE_KEY_FILE:-/var/lib/sops-nix/key.txt}"
if [[ ! -r "$key_file" ]]; then
  echo "Cannot read key file: $key_file" >&2
  echo "Hint: run with sudo or export SOPS_AGE_KEY_FILE to a readable key path." >&2
  exit 1
fi

if [[ $# -eq 2 ]]; then
  output_file="$2"
  umask 077
  SOPS_AGE_KEY_FILE="$key_file" nix shell nixpkgs#sops -c sops -d "$input_file" > "$output_file"
  echo "Decrypted: $output_file"
else
  SOPS_AGE_KEY_FILE="$key_file" nix shell nixpkgs#sops -c sops -d "$input_file"
fi
