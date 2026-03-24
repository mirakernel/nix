{ config, lib, codex-cli-nix, playwright-web-flake, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  codexBase = codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  codexPatched = codexBase.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.autoPatchelfHook ];
    buildInputs = (old.buildInputs or []) ++ [
      pkgs.zlib
      pkgs.stdenv.cc.cc.lib
    ];
  });
  playwrightDriver = playwright-web-flake.packages.${system}.playwright-driver;
  playwrightBrowsersPath =
    builtins.unsafeDiscardStringContext "${playwrightDriver.browsers}";
in {
  options.my.hm.ai = {
    enable = lib.mkEnableOption "AI-инструменты и MCP Playwright для пользователя";
  };

  config = lib.mkIf config.my.hm.ai.enable {
    home.packages = [
      codexPatched
      pkgs.claude-code
      pkgs.docker
      playwrightDriver
      (pkgs.writeShellApplication {
        name = "claude-ssh-mcp-add";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          if [ "$#" -lt 2 ]; then
            echo "Использование: claude-ssh-mcp-add <host> <user> [--password <password>]" >&2
            exit 1
          fi

          host="$1"
          user="$2"
          shift 2

          config_file=".mcp.json"
          tmp_file="$(mktemp)"

          if [ ! -f "$config_file" ]; then
            echo '{"mcpServers":{}}' > "$config_file"
          fi

          if [ "$#" -eq 0 ]; then
            jq --arg host "$host" --arg user "$user" --arg key "$HOME/.ssh/id_ed25519" '
              .mcpServers.ssh = {
                "type": "stdio",
                "command": "npx",
                "args": [
                  "-y",
                  "ssh-mcp",
                  "--",
                  ("--host=" + $host),
                  ("--user=" + $user),
                  ("--key=" + $key)
                ]
              }
            ' "$config_file" > "$tmp_file"
          elif [ "$#" -eq 2 ] && [ "$1" = "--password" ]; then
            jq --arg host "$host" --arg user "$user" --arg password "$2" '
              .mcpServers.ssh = {
                "type": "stdio",
                "command": "npx",
                "args": [
                  "-y",
                  "ssh-mcp",
                  "--",
                  ("--host=" + $host),
                  ("--user=" + $user),
                  ("--password=" + $password)
                ]
              }
            ' "$config_file" > "$tmp_file"
          else
            rm -f "$tmp_file"
            echo "Использование: claude-ssh-mcp-add <host> <user> [--password <password>]" >&2
            exit 1
          fi

          mv "$tmp_file" "$config_file"
          echo "SSH MCP записан в $config_file для текущего проекта"
        '';
      })
      (pkgs.writeShellApplication {
        name = "codex-ssh";
        text = ''
          if [ "$#" -lt 2 ]; then
            echo "Использование: codex-ssh <host> <user> [--password <password>] [-- <аргументы codex>]" >&2
            exit 1
          fi

          host="$1"
          user="$2"
          shift 2

          auth_args=("--key=$HOME/.ssh/id_ed25519")

          if [ "$#" -ge 2 ] && [ "$1" = "--password" ]; then
            auth_args=("--password=$2")
            shift 2
          fi

          if [ "$#" -gt 0 ] && [ "$1" = "--" ]; then
            shift
          fi

          exec ${codexPatched}/bin/codex \
            -c 'mcp_servers.ssh.command="npx"' \
            -c "mcp_servers.ssh.args=[\"-y\",\"ssh-mcp\",\"--\",\"--host=$host\",\"--user=$user\",\"''${auth_args[0]}\"]" \
            "$@"
        '';
      })
    ];

    home.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${playwrightDriver.browsers}";
      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    };

    home.activation.configureClaudePlaywright =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CLAUDE_CONFIG="$HOME/.claude.json"

        if [ ! -f "$CLAUDE_CONFIG" ]; then
          echo '{}' > "$CLAUDE_CONFIG"
        fi

        CHROMIUM_DIR=$(ls ${playwrightBrowsersPath} | grep '^chromium-' | head -n 1)

        if [ -z "$CHROMIUM_DIR" ]; then
          echo "Не найден chromium в ${playwrightBrowsersPath}" >&2
          exit 1
        fi

        ${pkgs.jq}/bin/jq --arg execPath "${playwrightBrowsersPath}/$CHROMIUM_DIR/chrome-linux64/chrome" '
          .mcpServers.playwright = {
            "type": "stdio",
            "command": "npx",
            "args": [
              "@playwright/mcp@latest",
              "--browser",
              "chromium",
              "--executable-path",
              $execPath
            ],
            "env": {
              "PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS": "true",
              "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD": "1",
              "PWMCP_PROFILES_DIR_FOR_TEST": (env.HOME + "/.local/share/playwright-mcp/profiles")
            }
          }
          | .mcpServers.context7 = {
            "type": "stdio",
            "command": "npx",
            "args": ["-y", "@upstash/context7-mcp@latest"]
          }
        ' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp"

        mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"

        if docker mcp gateway run --help >/dev/null 2>&1; then
          ${pkgs.jq}/bin/jq '
            .mcpServers.MCP_DOCKER = {
              "type": "stdio",
              "command": "docker",
              "args": ["mcp", "gateway", "run"]
            }
          ' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp"
        else
          ${pkgs.jq}/bin/jq 'del(.mcpServers.MCP_DOCKER)' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp"
        fi

        mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
      '';

    home.activation.configureCodexMcp =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CODEX_CONFIG_DIR="$HOME/.codex"

        mkdir -p "$CODEX_CONFIG_DIR"
        CHROMIUM_DIR=$(ls ${playwrightBrowsersPath} | grep '^chromium-' | head -n 1)

        if [ -z "$CHROMIUM_DIR" ]; then
          echo "Не найден chromium в ${playwrightBrowsersPath}" >&2
          exit 1
        fi

        ${codexPatched}/bin/codex mcp remove playwright >/dev/null 2>&1 || true
        ${codexPatched}/bin/codex mcp add playwright --env PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true --env PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 --env PWMCP_PROFILES_DIR_FOR_TEST="$HOME/.local/share/playwright-mcp/profiles" -- \
          npx @playwright/mcp@latest --browser chromium --executable-path "${playwrightBrowsersPath}/$CHROMIUM_DIR/chrome-linux64/chrome"

        ${codexPatched}/bin/codex mcp remove context7 >/dev/null 2>&1 || true
        ${codexPatched}/bin/codex mcp add context7 -- \
          npx -y @upstash/context7-mcp@latest

        ${codexPatched}/bin/codex mcp remove MCP_DOCKER >/dev/null 2>&1 || true
        if docker mcp gateway run --help >/dev/null 2>&1; then
          ${codexPatched}/bin/codex mcp add MCP_DOCKER -- \
            docker mcp gateway run
        fi

        ${codexPatched}/bin/codex mcp remove ssh >/dev/null 2>&1 || true
      '';
  };
}
