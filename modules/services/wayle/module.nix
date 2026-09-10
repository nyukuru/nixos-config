{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    mkPackageOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.types)
    lines
    str
    ;

  toml = pkgs.formats.toml {};
  cfg = config.nyu.services.wayle;

  wrapConfigHome = package:
    pkgs.symlinkJoin {
      name = "${package.pname or package.name}-wrapped";
      paths = [package];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        for bin in "$out"/bin/*; do
          wrapProgram "$bin" --set XDG_CONFIG_HOME /etc
        done
      '';
    };
in {
  options.nyu.services.wayle = {
    enable = mkEnableOption "Wayle desktop shell.";

    package =
      mkPackageOption pkgs "wayle" {}
      // {apply = wrapConfigHome;};

    config = mkOption {
      type = toml.type;
      default = {};
      description = "Wayle configuration, written to /etc/wayle/config.toml.";
    };

    styles = mkOption {
      type = lines;
      default = "";
      description = ''
        Custom SCSS written to /etc/wayle/styles/index.scss. Layered on top
        of Wayle's built-in stylesheet; the escape hatch for tweaks not
        exposed through {option}`config` (see Wayle's "Custom styles" guide).
      '';
    };

    systemd.target = mkOption {
      type = str;
      default = "graphical-session.target";
      description = "Systemd user target that the wayle service attaches to.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc = {
        "wayle/config.toml".source = toml.generate "wayle-config.toml" cfg.config;
        "wayle/styles/index.scss" = mkIf (cfg.styles != "") {
          text = cfg.styles;
        };
      };
    };

    systemd.user.services.wayle = {
      description = "Wayle desktop shell";

      after = [cfg.systemd.target];
      partOf = [cfg.systemd.target];
      wantedBy = [cfg.systemd.target];

      unitConfig = {
        StartLimitIntervalSec = 30;
        StartLimitBurst = 5;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/wayle shell";
        Restart = "on-failure";
        RestartSec = 3;
        Slice = "session.slice";
      };
    };
  };
}
