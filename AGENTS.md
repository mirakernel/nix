# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` and `flake.lock` define inputs/outputs for NixOS and Home Manager.
- `hosts/<name>/` contains host-specific NixOS configs (e.g., `hosts/tsunami/configuration.nix`).
- `modules/nixos/` holds reusable NixOS modules (system-level services).
- `modules/home-manager/` holds Home Manager modules (user-level config).
- `home/<user>/home.nix` is the Home Manager entrypoint per user.
- `disko/` contains disk layout definitions for Disko.
- `secrets/` is for encrypted secrets; see `.gitignore` note in README.

## Build, Test, and Development Commands
- `./nixos-install.sh --host <name>` runs Disko, generates hardware config, and installs from flake.
- `./nixos-update.sh` updates `flake.lock`, rebuilds NixOS, and applies Home Manager.
- `nixos-rebuild switch --flake .#<host>` rebuilds a host directly.
- `home-manager switch --flake /etc/nixos#<user>` applies user config.
- `nix flake update` refreshes inputs in `flake.lock`.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and standard Nixpkgs formatting.
- Keep module names descriptive and scoped under `my.*` options (see existing modules).
- Prefer clear, concise attribute names and short inline comments only when needed.

## Module Style Guide
- Use this module shape by default: `{ config, lib, pkgs, ... }: { options = ...; config = lib.mkIf ...; }`.
- For Home Manager modules, define options under `my.hm.<name>.enable`.
- For NixOS modules, define options under `my.nixos.<name>.enable` (or existing project namespace when already established).
- Keep one responsibility per module: avoid mixing unrelated services/apps in one file.
- Prefer declarative user/system services inside modules (`systemd.user.services` or `systemd.services`) instead of ad-hoc shell hooks.
- Put user-facing packages in `home.packages`; put system-level packages in `environment.systemPackages`.
- Keep defaults explicit and local to the module; avoid hidden magic from unrelated files.
- Reuse `config.xdg.*` paths for user configs/data instead of hardcoded `/home/<user>`.
- Add comments only where intent is non-obvious (why), not for trivial assignments (what).
- When adding a new module file, also wire it in the proper entrypoint (`home/<user>/home.nix` or `hosts/<name>/configuration.nix`) and set its `my.*.enable` flag explicitly.

## Testing Guidelines
- No automated test suite is defined.
- Validate changes by running `nixos-rebuild switch` and, if relevant, `home-manager switch`.
- If touching Disko configs, review the target device path before applying.

## Commit & Pull Request Guidelines
- Commit messages are short and direct, often lowercase (e.g., `fix`, `term + plasma`, `update`).
- Keep commits focused on a single change set.
- For PRs: include a brief summary, affected hosts/modules, and any manual verification steps.

## Security & Configuration Tips
- Do not store unencrypted secrets in `secrets/`; follow the `.gitignore` rules.
- Disk operations are destructive; double-check `disko/<host>.nix` before running install.

## Language & Documentation
- Respond to users in Russian.
- Write descriptions and README content in Russian.
