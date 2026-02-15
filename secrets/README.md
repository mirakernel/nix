# Секреты VPN (sops-nix)

1. При первой сборке `sops-nix` автоматически создаст age-ключ хоста по пути:
   `/var/lib/sops-nix/key.txt`
2. Зашифруйте шаблон в реальный файл:
   `sops -e secrets/vpn.yaml.example > secrets/vpn.yaml`
3. Храните `secrets/vpn.yaml` в git только в зашифрованном виде.

Ожидаемые ключи:
- `vpn/singbox_uuid`

Для NetBird setup keys используйте:
- `secrets/netbird.yaml.example` -> `secrets/netbird.yaml`
- ключи: `netbird/mirakernel_setup_key`, `netbird/techmind_setup_key`

Для удобного `sops -e ...` без `--age`:
- укажите ваш `age1...` в `.sops.yaml`
- после этого можно шифровать так: `sops -e secrets/netbird.yaml.example > secrets/netbird.yaml`
