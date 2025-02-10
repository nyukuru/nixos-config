{
  pkgs,
  lib,
  ...
}: let
  inherit 
    (lib.modules)
    mkDefaultAttr
    mkDefault
    mkForce
    ;

  inherit
    (lib.meta)
    getExe
    ;

in {
  environment = {
    defaultPackages = mkForce [];

    systemPackages = with pkgs; [
      # Network transfers.
      curl
      wget
      rsync
      git
      cifs-utils

      # Text editor.
      vim
    ];

    variables = mkDefaultAttr {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      BROWSER = "firefox";
      FLAKE = "~/nixos-config";
    };

    shellAliases = {
      nr = "nix-store --verify; ${getExe pkgs.nh} os switch";
    };
  };

  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  time = {
    timeZone = mkDefault "America/New_York";
    hardwareClockInLocalTime = true;
  };
}
