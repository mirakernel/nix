# VPN secrets (sops-nix)

1. On first rebuild, `sops-nix` will generate a host age key at:
   `/var/lib/sops-nix/key.txt`
2. Encrypt the template into the real file:
   `sops -e secrets/vpn.yaml.example > secrets/vpn.yaml`
3. Keep `secrets/vpn.yaml` encrypted in git.

Expected keys:
- `vpn/singbox_uuid`
