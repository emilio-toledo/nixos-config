{
  config,
  pkgs,
  lib,
  ...
}:

let
  sshKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
  allowedSignersPath = "${config.home.homeDirectory}/.ssh/allowed_signers";
in
{
  # Git and related VCS tools configuration
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "Emilio Toledo";
          email = "github@emiliotoledo.com";
          signingkey = sshKeyPath;
        };

        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = allowedSignersPath;
        };

        commit = {
          gpgSign = true;
        };

      };

      extraConfig = {
        init = {
          defaultBranch = "dev";
        };
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Emilio Toledo";
          email = "github@emiliotoledo.com";
        };

        revset-aliases = {
          "trunk()" = "dev@origin";
        };
        signing = {
          behavior = "own";
          backend = "ssh";
          key = sshKeyPath;
        };
      };
    };
  };
}
