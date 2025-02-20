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

  toml = pkgs.formats.toml {};

  cfg = config.modules.programs.dunst;

in {
  options.modules.programs.dunst = {
    enable = mkEnableOption "Dunst notification daemon.";
    package = mkPackageOption pkgs "dunst" {};

    settings = mkOption {
      type = toml.type;
      default = {};
      description = "Dunst settings (https://github.com/dunst-project/dunst/blob/master/docs/dunst.5.pod)";
    };
  };

  config = {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "dunst-wrapped";
	paths = cfg.package;
	nativeBuildInputs = [pkgs.makeWrapper];
	postBuild = ''
	  wrapProgram $out/bin/dunst \
	  --add-flags '-conf' \
	  --add-flags '${toml.generate "dunts.toml" cfg.settings}'
	'';
      })
    ];
  };
}
