{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault;
in {
  imports = [
    ./nyoo.nix
  ];

  users = {
    defaultUserShell = pkgs.zsh;

    allowNoPasswordLogin = mkDefault false;
    enforceIdUniqueness = mkDefault true;

    mutableUsers = false;
  };
}
