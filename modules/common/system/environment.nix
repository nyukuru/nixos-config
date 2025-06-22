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
    defaultPackages = mkForce (with pkgs; [
      # Network transfers.
      curl
      wget
      rsync
      git
      cifs-utils

      # Text editor.
      vim
    ]);

    variables = {
      SUDO_EDITOR = "vim";
      EDITOR = "vim";
      VISUAL = "vim";
      BROWSER = "firefox";
    };

    shellAliases = {
      # Nix-Rebuild
      nr = "nix-store --verify; ${getExe pkgs.nh} os switch -a";
      # Nix-Rebuild-Update
      nru = "nix-store --verify; ${getExe pkgs.nh} os switch -au";
      # Garbage-Collect
      gc = "${getExe pkgs.nh} clean all -ak 5";

      # Always ask when overwritting
      cp = "cp -i";

      # List view by default
      ls = "ls -l";
      la = "ls -la";

      pls = "sudo";
      gis = "git status";
    };
  };

  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  time = {
    timeZone = mkDefault "America/New_York";
    hardwareClockInLocalTime = true;
  };
}
