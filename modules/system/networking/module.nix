{
  lib,
  config,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkDefault
    mkIf
    ;

  inherit
    (lib.lists)
    optionals
    ;

  inherit
    (lib.types)
    listOf
    str
    ;

  cfg = config.nyu.networking;
in {
  imports = [
    ./firewall.nix
    ./ssh.nix
  ];

  options.nyu.networking = {
    enable = mkEnableOption "Networking" // {default = true;};

    nameservers = {
      cloudflare = mkEnableOption "Cloudflare DNS" // {default = true;};
      quad9 = mkEnableOption "Quad9 DNS" // {default = true;};

      extra = mkOption {
        type = listOf str;
        default = [];
        description = "Location of nameservers to use.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.resolved = {
      enable = true;
      settings.Resolve.DNSSEC = false;
    };

    systemd = {
      network.wait-online.enable = false;
      services.NetworkManager-wait-online.enable = false;
    };

    networking = {
      useDHCP = false;
      useNetworkd = !config.networking.useDHCP;
      #useHostResolvConf = true;

      nameservers =
        cfg.nameservers.extra
        ++ optionals cfg.nameservers.cloudflare [
          "1.1.1.2"
          "2606:4700:4700::1112"
          "1.0.0.2"
          "2606:4700:4700::1002"
        ]
        ++ optionals cfg.nameservers.quad9 [
          "9.9.9.9"
          "2620:fe::9"
          "149.112.112.112"
          "2620:fe::fe"
        ];

      networkmanager = {
        enable = mkDefault true;
        wifi = {
          macAddress = mkDefault "random";
          powersave = mkDefault true;
        };
      };
    };
  };
}
