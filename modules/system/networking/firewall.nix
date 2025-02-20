{
  pkgs,
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
    mkIf
    ;

  inherit
    (lib.types)
    submodule
    attrsOf
    lines
    enum
    str
    ;

  cfg = config.modules.system.networking.firewall;
in {
  # TODO
  options.modules.system.networking.firewall = {
    enable = mkEnableOption "Firewall." // {default = true;};

    tables = mkOption {
      type = attrsOf (submodule
        ({name, ...}: {
          options = {
            enable = mkEnableOption "${name}" // {default = true;};

            name = mkOption {
              type = str;
              default = name;
              description = "Table name.";
            };

            content = mkOption {
              type = lines;
              default = "";
              description = "The table content.";
            };

            family = mkOption {
              description = "Table family.";
              type = enum [
                "ip"
                "ip6"
                "inet"
                "arp"
                "bridge"
                "netdev"
              ];
            };
          };
        }));
      default = {};
      description = "nftables configs";
    };
  };

  config = mkIf (config.modules.system.networking.enable && cfg.enable) {
    networking = {
      firewall = {
        enable = true;
        package = pkgs.nftables;
        pingLimit = "1/minute burst 5 packets";
      };

      nftables = {
        enable = true;
        flushRuleset = true;

        tables =
          {
            fail2ban = {
              family = "ip";
              content = ''
                chain input {
                  type filter hook input priority 100;
                }
              '';
            };
          }
          // cfg.tables;
      };
    };
  };
}
