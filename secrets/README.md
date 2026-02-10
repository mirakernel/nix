# Секреты VPN (sops-nix)

1. При первой сборке `sops-nix` автоматически создаст age-ключ хоста по пути:
   `/var/lib/sops-nix/key.txt`
2. Зашифруйте шаблон в реальный файл:
   `sops -e secrets/vpn.yaml.example > secrets/vpn.yaml`
3. Храните `secrets/vpn.yaml` в git только в зашифрованном виде.

Ожидаемые ключи:
- `vpn/singbox_uuid`
