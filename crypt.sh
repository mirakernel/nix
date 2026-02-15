#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./crypt.sh <input-file> [output-file]

Encrypt file with sops via nix shell.
Examples:
  ./crypt.sh secrets/netbird.yaml.example
  ./crypt.sh secrets/netbird.yaml.example secrets/netbird.yaml
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

if [[ $# -eq 2 ]]; then
  output_file="$2"
else
  if [[ "$input_file" == *.example ]]; then
    output_file="${input_file%.example}"
  else
    output_file="${input_file}.enc"
  fi
fi

umask 077
sops_args=( -e )
if [[ "$input_file" == *.yaml || "$input_file" == *.yml || "$input_file" == *.yaml.example || "$input_file" == *.yml.example ]]; then
  sops_args+=( --input-type yaml --output-type yaml )
fi

nix shell nixpkgs#sops -c sops "${sops_args[@]}" "$input_file" > "$output_file"
echo "Encrypted: $output_file"
