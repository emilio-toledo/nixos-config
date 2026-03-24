{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.sandbox;

  sandboxScript = pkgs.writeShellScriptBin "sandbox" ''
    set -euo pipefail

    usage() {
      echo "Usage: sandbox <command> [path]"
      echo ""
      echo "Commands:"
      echo "  start [path]   Start sandbox with path mounted as /workspace (default: .)"
      echo "  enter          Enter a running sandbox"
      echo "  status         Show sandbox status"
      echo ""
      echo "Examples:"
      echo "  sandbox start                    # mount current directory"
      echo "  sandbox start .                  # mount current directory"
      echo "  sandbox start ~/projects/myapp   # mount specific path"
      echo "  sandbox enter                    # get a shell inside"
    }

    require_root() {
      if [ "$(id -u)" -ne 0 ]; then
        echo "Error: sandbox requires root. Run with sudo." >&2
        exit 1
      fi
    }

    CONTAINER_NAME="${cfg.name}"
    CONF_FILE="/etc/nixos-containers/$CONTAINER_NAME.conf"
    CONF_OVERRIDE="/etc/nixos-containers/$CONTAINER_NAME.conf.dynamic"
    STATE_FILE="/run/sandbox-workspace"

    case "''${1:-}" in
      start)
        require_root

        TARGET_PATH="''${2:-.}"
        TARGET_PATH="$(realpath "$TARGET_PATH")"

        if [ ! -d "$TARGET_PATH" ]; then
          echo "Error: '$TARGET_PATH' is not a directory" >&2
          exit 1
        fi

        # Stop any existing sandbox
        nixos-container stop "$CONTAINER_NAME" 2>/dev/null || true

        # Restore static conf in case a previous run didn't clean up
        ln -sfn /etc/static/nixos-containers/$CONTAINER_NAME.conf "$CONF_FILE"
        rm -f "$CONF_OVERRIDE"

        echo "Starting sandbox with workspace: $TARGET_PATH"

        # Replace the conf symlink with a copy that has our dynamic bind mount
        cp "$(readlink -f "$CONF_FILE")" "$CONF_OVERRIDE"
        CALLER_HOME="$(getent passwd "''${SUDO_USER:-$USER}" | cut -d: -f6)"
        SANDBOX_HOME="$CALLER_HOME/.sandbox-home"
        mkdir -p "$SANDBOX_HOME"
        chown -R "''${SUDO_UID:-$(id -u)}:''${SUDO_GID:-$(id -g)}" "$SANDBOX_HOME"
        ${pkgs.gnused}/bin/sed -i "s|^EXTRA_NSPAWN_FLAGS=.*|EXTRA_NSPAWN_FLAGS=\"--bind=$TARGET_PATH:/workspace --bind=$SANDBOX_HOME:/home/sandbox\"|" "$CONF_OVERRIDE"
        ln -sfn "$CONF_OVERRIDE" "$CONF_FILE"

        # Save workspace path for status/enter
        echo "$TARGET_PATH" > "$STATE_FILE"

        # Ensure cleanup runs on exit (normal, error, or signal)
        cleanup() {
          nixos-container stop "$CONTAINER_NAME" 2>/dev/null || true
          rm -f "$CONF_OVERRIDE"
          ln -sfn /etc/static/nixos-containers/$CONTAINER_NAME.conf "$CONF_FILE"
          rm -f "$STATE_FILE"
          echo "Sandbox stopped."
        }
        trap cleanup EXIT

        nixos-container start "$CONTAINER_NAME"

        echo ""
        echo "Sandbox running. Workspace: $TARGET_PATH -> /workspace"
        echo ""

        # Immediately enter the sandbox, cleanup runs on exit via trap
        LEADER_PID=$(machinectl show "$CONTAINER_NAME" -p Leader --value)
        nsenter -a -t "$LEADER_PID" -- su -l sandbox
        ;;

      enter)
        require_root
        if ! nixos-container status "$CONTAINER_NAME" &>/dev/null; then
          echo "Sandbox is not running. Start it with: sudo sandbox start [path]" >&2
          exit 1
        fi
        LEADER_PID=$(machinectl show "$CONTAINER_NAME" -p Leader --value)
        nsenter -a -t "$LEADER_PID" -- su -l sandbox
        ;;

      status)
        if nixos-container status "$CONTAINER_NAME" &>/dev/null; then
          echo "Sandbox is running."
          if [ -f "$STATE_FILE" ]; then
            echo "Workspace: $(cat "$STATE_FILE") -> /workspace"
          fi
        else
          echo "Sandbox is not running."
        fi
        ;;

      *)
        usage
        ;;
    esac
  '';
in
{
  options.sandbox = {
    enable = mkEnableOption "sandboxed NixOS container for agentic CLI tools";

    name = mkOption {
      type = types.str;
      default = "sandbox";
      description = "Name of the container";
    };

    privateNetwork = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to isolate the container network. Set to false to allow internet access for agentic tools.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install in the sandbox";
    };

    maxMemory = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Memory limit for the container (systemd MemoryMax). null for unlimited.";
    };

    maxCPU = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "CPU quota for the container (systemd CPUQuota). null for unlimited.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ sandboxScript ];

    containers.${cfg.name} = {
      autoStart = false;
      privateNetwork = cfg.privateNetwork;
      ephemeral = true;

      config =
        { pkgs, ... }:
        let
          sccacheWrapper = pkgs.writeShellScript "sccache-wrapper" ''
            exec ${pkgs.sccache}/bin/sccache "$@"
          '';
        in
        {
          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "claude-code"
            ];

          system.stateVersion = "25.05";

          networking = mkIf (!cfg.privateNetwork) {
            useHostResolvConf = mkForce true;
          };

          environment.systemPackages =
            with pkgs;
            [
              claude-code
              git
              rustup
              mold
              sccache
              gcc
              python313
              python315
              uv
              openssl
              openssl.dev
              gnumake
              pkg-config
              nodejs
              pnpm
              jujutsu
            ]
            ++ cfg.extraPackages;

          programs.fish.enable = true;

          users.users.sandbox = {
            isNormalUser = true;
            home = "/home/sandbox";
            shell = pkgs.fish;
            uid = 1000;
            group = "users";
          };

          # Persist rustup/cargo across ephemeral restarts (home is bind-mounted)
          environment.variables = {
            RUSTUP_HOME = "/home/sandbox/.rustup";
            CARGO_HOME = "/home/sandbox/.cargo";
            CARGO_TARGET_DIR = "target/sandbox";
            RUSTC_WRAPPER = "${sccacheWrapper}";
            SCCACHE_SERVER_UDS = "/tmp/sccache.sock";
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
            ];
          };

          environment.extraInit = ''
            export PATH="/home/sandbox/.venvs/default/bin:$CARGO_HOME/bin:$PATH"
          '';

          # Add venv + cargo to fish PATH (fish doesn't source /etc/profile)
          programs.fish.shellInit = ''
            fish_add_path --prepend /home/sandbox/.venvs/default/bin $CARGO_HOME/bin
          '';

          # Start in /workspace on login
          programs.fish.interactiveShellInit = ''
            cd /workspace 2>/dev/null; or true
          '';

          # Required for rustup-installed binaries and PyPI native extensions
          programs.nix-ld.enable = true;
          programs.nix-ld.libraries = [
            pkgs.stdenv.cc.cc.lib # libstdc++.so.6
          ];

          # Install PyPI packages into a persistent venv (home is bind-mounted)
          systemd.services.python-venv-setup = {
            description = "Set up Python virtual environment with PyPI packages";
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            path = [
              pkgs.uv
              pkgs.python313
            ];
            serviceConfig = {
              Type = "oneshot";
              User = "sandbox";
              Group = "users";
              ExecStart = pkgs.writeShellScript "setup-python-venv" ''
                set -euo pipefail
                VENV="/home/sandbox/.venvs/default"
                rm -rf "$VENV"
                ${pkgs.uv}/bin/uv venv "$VENV" --python ${pkgs.python313}/bin/python
                ${pkgs.uv}/bin/uv pip install --python "$VENV/bin/python" \
                   claude-agent-sdk ouroboros-ai[claude]
              '';
            };
          };

          # Pre-start sccache server (auto-daemonization fails inside nspawn)
          systemd.services.sccache = {
            description = "sccache daemon";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "forking";
              ExecStart = "${pkgs.sccache}/bin/sccache --start-server";
              ExecStop = "${pkgs.sccache}/bin/sccache --stop-server";
              User = "sandbox";
              Group = "users";
              Environment = [
                "SCCACHE_IDLE_TIMEOUT=0"
                "SCCACHE_DIR=/home/sandbox/.cache/sccache"
                "SCCACHE_SERVER_UDS=/tmp/sccache.sock"
              ];
            };
          };

          security.sudo.enable = false;

          nix.settings = {
            sandbox = true;
            allowed-users = [ "sandbox" ];
          };
        };
    };

    systemd.services."container@${cfg.name}" = {
      serviceConfig = {
        MemoryMax = mkIf (cfg.maxMemory != null) cfg.maxMemory;
        CPUQuota = mkIf (cfg.maxCPU != null) cfg.maxCPU;
      };
    };
  };
}
