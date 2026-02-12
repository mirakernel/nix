{ codex-cli-nix, pkgs, ... }:
let
  codexBase = codex-cli-nix.packages.${pkgs.system}.default;
  codexPatched = codexBase.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.autoPatchelfHook ];
    buildInputs = (old.buildInputs or []) ++ [
      pkgs.zlib
      pkgs.stdenv.cc.cc.lib
    ];
  });
in {
  home.packages = [
    codexPatched
  ];
}
