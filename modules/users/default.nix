{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.customUsers;
in
{
  options.customUsers = {
    enable = mkEnableOption "custom user management system";

    users = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "this user" // {
              default = true;
            };

            shell = mkOption {
              type = types.package;
              default = pkgs.bash;
              description = "The user's shell";
            };

            extraGroups = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Additional groups for the user";
            };

            hashedPasswordFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to file containing hashed password";
            };

            secretFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path to the age-encrypted secret file (relative to repository root)";
            };

            isNormalUser = mkOption {
              type = types.bool;
              default = true;
              description = "Whether this is a normal user account";
            };
          };
        }
      );
      default = { };
      description = "Set of users to create";
    };
  };

  config = mkIf cfg.enable {
    users.mutableUsers = false;

    age.secrets = mapAttrs' (
      name: userCfg:
      nameValuePair name {
        file = userCfg.secretFile;
        owner = name;
        group = if userCfg.isNormalUser then "users" else name;
      }
    ) (filterAttrs (n: v: v.enable && v.secretFile != null) cfg.users);

    users.users = mapAttrs (name: userCfg: {
      inherit (userCfg) isNormalUser extraGroups shell;
      hashedPasswordFile =
        if userCfg.hashedPasswordFile != null then
          userCfg.hashedPasswordFile
        else if userCfg.secretFile != null then
          config.age.secrets.${name}.path
        else
          null;
    }) (filterAttrs (n: v: v.enable) cfg.users);

    users.groups = listToAttrs (
      map (name: nameValuePair name { }) (
        filter (n: cfg.users.${n}.enable && !cfg.users.${n}.isNormalUser) (attrNames cfg.users)
      )
    );
  };
}
