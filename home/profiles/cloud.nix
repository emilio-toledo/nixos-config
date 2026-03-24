{
  pkgs,
  ...
}:
{
  programs.awscli = {
    enable = true;

    settings = {
      "sso-session xcentivize" = {
        sso_start_url = "https://xcentivize.awsapps.com/start";
        sso_region = "us-east-1";
      };

      "profile management" = {
        sso_session = "xcentivize";
        sso_account_id = "715039652512";
        sso_role_name = "AdministratorAccess";
        region = "us-east-1";
      };

      "profile shared-services" = {
        sso_session = "xcentivize";
        sso_account_id = "335158494916";
        sso_role_name = "AdministratorAccess";
        region = "us-east-1";
      };

      "profile production" = {
        sso_session = "xcentivize";
        sso_account_id = "720035686101";
        sso_role_name = "DeveloperAccess";
        region = "us-east-1";
      };

      "profile default" = {
        sso_session = "xcentivize";
        sso_account_id = "392424878246";
        sso_role_name = "DeveloperAccess";
        region = "us-east-1";
      };
    };
  };

  home.packages = with pkgs; [
    opentofu
  ];
}
