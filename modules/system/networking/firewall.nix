{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.types) enum;

  cfg = config.modules.system.networking.firewall;
in {
  # TODO
  options.modules.system.networking.firewall = {
    enable = mkEnableOption "Firewall." // {default = true;};
  };

  config = mkMerge [
    {
      networking.firewall.enable = cfg.enable;
    }

    (mkIf (config.modules.system.networking.enable && cfg.enable) {
      networking = {
        firewall = {
          package = pkgs.nftables;
          pingLimit = "1/minute burst 5 packets";
        };

        nftables = {
          enable = true;
        };
      };
    })
  ];
}
