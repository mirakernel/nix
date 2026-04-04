{ config, lib, codex-cli-nix, pkgs, ... }:
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
  chromiumExecutable = "${pkgs.chromium}/bin/chromium";
  sopsEnabled = lib.attrByPath [ "my" "hm" "sops" "enable" ] false config;
  directusSopsConfig = lib.mkIf sopsEnabled {
    sops = {
      secrets."directus/token" = {
        sopsFile = ../../secrets/directus.yaml;
      };

      templates."directus-mcp.env" = {
        content = ''
          DIRECTUS_MCP_TOKEN=${config.sops.placeholder."directus/token"}
        '';
      };
    };
  };
  claudeDirectusSnippet = lib.optionalString sopsEnabled ''
    ${pkgs.claude-code}/bin/claude mcp remove --scope user directus >/dev/null 2>&1 || true
    if [ -r "$DIRECTUS_TOKEN_FILE" ]; then
      DIRECTUS_TOKEN=$(${pkgs.coreutils}/bin/tr -d '\n' < "$DIRECTUS_TOKEN_FILE")
      ${pkgs.claude-code}/bin/claude mcp add --scope user --transport http directus http://localhost:8055/mcp \
        --header "Authorization: Bearer $DIRECTUS_TOKEN" >/dev/null 2>&1
    fi
  '';
  codexDirectusSnippet = lib.optionalString sopsEnabled ''
    ${codexPatched}/bin/codex mcp remove directus >/dev/null 2>&1 || true
    if [ -r "$DIRECTUS_ENV_FILE" ]; then
      set -a
      . "$DIRECTUS_ENV_FILE"
      set +a
      ${codexPatched}/bin/codex mcp add directus --url http://localhost:8055/mcp --bearer-token-env-var DIRECTUS_MCP_TOKEN
    fi
  '';
in {
  options.my.hm.ai = {
    enable = lib.mkEnableOption "AI-инструменты и MCP Playwright для пользователя";
    claude.enable = lib.mkEnableOption "Claude Code для пользователя";
  };

  config = lib.mkIf config.my.hm.ai.enable (lib.mkMerge [
    directusSopsConfig
    {
      warnings = lib.optional (!sopsEnabled) "sops-nix отключен: Directus MCP не будет настроен для Claude/Codex.";

      home.packages = [
      codexPatched
      pkgs.docker
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
      ] ++ lib.optionals config.my.hm.ai.claude.enable [
        pkgs.claude-code
      ];

      home.sessionVariables = {
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
      };

      home.activation.configureClaudePlaywright = lib.mkIf config.my.hm.ai.claude.enable
        (lib.hm.dag.entryAfter (if sopsEnabled then [ "sops-nix" ] else [ "writeBoundary" ]) ''
          CLAUDE_CONFIG="$HOME/.claude.json"
          ${lib.optionalString sopsEnabled ''DIRECTUS_TOKEN_FILE="${config.sops.secrets."directus/token".path}"''}

          if [ ! -f "$CLAUDE_CONFIG" ]; then
            echo '{}' > "$CLAUDE_CONFIG"
          fi

          if [ ! -x "${chromiumExecutable}" ]; then
            echo "Не найден исполняемый файл chromium: ${chromiumExecutable}" >&2
            exit 1
          fi

          ${pkgs.jq}/bin/jq --arg execPath "${chromiumExecutable}" '
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

          ${claudeDirectusSnippet}
        '');

      home.activation.configureCodexMcp =
        lib.hm.dag.entryAfter (if sopsEnabled then [ "sops-nix" ] else [ "writeBoundary" ]) ''
          CODEX_CONFIG_DIR="$HOME/.codex"
          ${lib.optionalString sopsEnabled ''DIRECTUS_ENV_FILE="${config.sops.templates."directus-mcp.env".path}"''}

          mkdir -p "$CODEX_CONFIG_DIR"
          if [ ! -x "${chromiumExecutable}" ]; then
            echo "Не найден исполняемый файл chromium: ${chromiumExecutable}" >&2
            exit 1
          fi

          ${codexPatched}/bin/codex mcp remove playwright >/dev/null 2>&1 || true
          ${codexPatched}/bin/codex mcp add playwright --env PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true --env PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 --env PWMCP_PROFILES_DIR_FOR_TEST="$HOME/.local/share/playwright-mcp/profiles" -- \
            npx @playwright/mcp@latest --browser chromium --executable-path "${chromiumExecutable}"

          ${codexPatched}/bin/codex mcp remove context7 >/dev/null 2>&1 || true
          ${codexPatched}/bin/codex mcp add context7 -- \
            npx -y @upstash/context7-mcp@latest

          ${codexDirectusSnippet}

          ${codexPatched}/bin/codex mcp remove MCP_DOCKER >/dev/null 2>&1 || true
          if docker mcp gateway run --help >/dev/null 2>&1; then
            ${codexPatched}/bin/codex mcp add MCP_DOCKER -- \
              docker mcp gateway run
          fi

          ${codexPatched}/bin/codex mcp remove ssh >/dev/null 2>&1 || true
        '';
    }
  ]);
}
