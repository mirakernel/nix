# Установка NixOS (tsunami) из NixOS Minimal ISO

Это инструкция по установке системы из этого репозитория на чистый диск с использованием `nixos-minimal` ISO.

## 1. Загрузитесь в NixOS Minimal ISO

После загрузки подключитесь к сети:

- проводная сеть обычно поднимается автоматически;
- для Wi‑Fi используйте `nmtui`.

Проверьте интернет:

```bash
ping -c 3 nixos.org
```

## 2. Разметьте диск через Disko

Используется Disko: https://nixos.wiki/wiki/Disko  
Все данные на целевом диске будут удалены.

В репозитории есть 2 готовых конфига:

- `disko/tsunami.nix` для физической машины (`/dev/nvme0n1`)
- `disko/vbox.nix` для VirtualBox (`/dev/sda`)

## 3. Получите репозиторий и запустите Disko

```bash
mkdir -p /mnt/etc
cd /mnt/etc
nix-shell -p git
git clone <URL_ЭТОГО_РЕПО> nixos
cd nixos
```

Запустите Disko (пример для `tsunami`):

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./disko/tsunami.nix
```

Для VirtualBox используйте:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./disko/vbox.nix
```

## 4. Сгенерируйте hardware-конфиг и добавьте в репозиторий

```bash
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/tsunami/hardware-configuration.nix
```

Добавьте импорт в `hosts/tsunami/configuration.nix`:

```nix
imports = [
  ./hardware-configuration.nix
  ../../modules/nixos/pantheon.nix
];
```

## 5. Поставьте систему из flake

```bash
nixos-install --flake /mnt/etc/nixos#tsunami --extra-experimental-features "nix-command flakes"
```

Во время установки задайте пароль `root`, если установщик попросит.

## 6. Перезагрузка

```bash
reboot
```

После загрузки:

- войдите под `root`;
- задайте пароль пользователю `kira`:

```bash
passwd kira
```

## 7. Дальше после первой загрузки

Обновить lock-файл и систему:

```bash
cd /etc/nixos
nix --extra-experimental-features "nix-command flakes" flake update
NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#tsunami
```

Для Home Manager:

```bash
sudo -u kira NIX_CONFIG="experimental-features = nix-command flakes" home-manager switch --flake /etc/nixos#kira
```

## Примечания

- В `flake` уже используется `nixos-unstable` и `home-manager` `master`.
- В `.gitignore` добавлено исключение для `secrets/*.yaml`, не храните незашифрованные секреты в репозитории.
