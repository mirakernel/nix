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

## 2. Разметьте диск и смонтируйте разделы

Пример для диска `/dev/nvme0n1` (UEFI, btrfs). Все данные на диске будут удалены.

```bash
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 513MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 513MiB 100%

mkfs.fat -F 32 /dev/nvme0n1p1
mkfs.btrfs -f /dev/nvme0n1p2

# создаем subvolume'ы
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

# монтируем subvolume'ы
mount -o subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/home
mount -o subvol=@home /dev/nvme0n1p2 /mnt/home
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

## 3. Сгенерируйте hardware-конфиг

```bash
nixos-generate-config --root /mnt
```

Скопируйте `hardware-configuration.nix` в этот репозиторий:

```bash
cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix
```

## 4. Получите репозиторий и добавьте hardware-конфиг

```bash
cd /mnt
nix-shell -p git
git clone <URL_ЭТОГО_РЕПО> nix
cd nix
cp /tmp/hardware-configuration.nix ./hosts/tsunami/hardware-configuration.nix
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
nixos-install --flake /mnt/nix#tsunami
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
cd ~/nix
nix flake update
sudo nixos-rebuild switch --flake .#tsunami
```

Для Home Manager:

```bash
home-manager switch --flake .#kira
```

## Примечания

- В `flake` уже используется `nixos-unstable` и `home-manager` `master`.
- В `.gitignore` добавлено исключение для `secrets/*.yaml`, не храните незашифрованные секреты в репозитории.
