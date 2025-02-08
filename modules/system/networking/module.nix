{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.modules.system.networking;
in {
  imports = [
    # Firewall options.
    ./firewall.nix

    # SSH server options.
    ./ssh.nix
  ];

  options.modules.system.networking = {
    enable = mkEnableOption "Networking." // {default = true;};
  };

  config = mkIf cfg.enable {
    # TODO: fix
    services.resolved.dnssec = mkDefault "allow-downgrade";
  };
}
