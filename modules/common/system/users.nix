{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault;
in {
  users = {
    defaultUserShell = pkgs.zsh;

    allowNoPasswordLogin = mkDefault false;
    enforceIdUniqueness = mkDefault true;

    mutableUsers = false;
  };
  assertions = [
    { assertion = config.users.users != [];
      message = "No users defined!";
    }
  ];
}
