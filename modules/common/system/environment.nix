{
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
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

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      BROWSER = "firefox";
    };

    shellAliases = {
      nr = "nix-store --verify; pushd ~/nixos-config; ${getExe pkgs.nh} os switch . -au; popd";
    };
  };

  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  time = {
    timeZone = mkDefault "America/New_York";
    hardwareClockInLocalTime = true;
  };
}
