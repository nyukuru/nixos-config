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
      # These will be overridden by default by nvim symlinking over vim
      SUDO_EDITOR = "vim";
      EDITOR = "vim";
      VISUAL = "vim";
      BROWSER = "firefox";
    };

    shellAliases = {
      # Nix-rebuild
      nr = "nix-store --verify; pushd ~/nixos-config; ${getExe pkgs.nh} os switch . -a; popd";
      # Nix-rebuild-update
      nru = "nix-store --verify; pushd ~/nixos-config; ${getExe pkgs.nh} os switch . -au; popd";
      # Garbage Collect
      gc = "${getExe pkgs.nh} clean all --keep 5";

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
