{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkPackageOption
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkForce
    mkIf
    ;

  inherit
    (lib.types)
    path
    lines 
    ;

  inherit
    (lib.lists)
    optional
    ;

  inherit
    (lib.meta)
    getExe
    ;

  cfg = config.nyu.programs.niri;
in {
  imports = [
    ../wayland-shared.nix
  ];

  options.nyu.programs.niri = {
    enable = mkEnableOption "Niri window manager.";
    package = mkPackageOption pkgs "niri" {};

    extraSessionCommands = mkOption {
      type = lines;
      default = "";
      description = ''
        Shell commands executed just before Niri is started.
      '';
    };

    configFile = mkOption {
      type = path;
      default = ./config.kdl;
      description = "Niri Config File";
    };

    xwayland = {
      enable = mkEnableOption "XWayland" // {default = true;};
    };
  };

  config = mkIf cfg.enable {
    programs = {
      niri.enable = mkForce false;
      uwsm.waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = getExe cfg.package;
      };
    };

    systemd.packages = [ cfg.package ];
    systemd.user.services.niri = {
      restartIfChanged = false;
      enableDefaultPath = false;
    };

    environment = {
      systemPackages =
        [cfg.package]
        ++ optional cfg.xwayland.enable pkgs.xwayland-satellite;

      etc."niri/config.kdl".source = cfg.configFile;
    };
  };
}
