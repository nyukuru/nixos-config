{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.types) int;

  cfg = config.nyu.networking.ssh;
in {
  options.nyu.networking.ssh = {
    enable = mkEnableOption "Secure Shell.";

    # Traps attackers trying to access an open default ssh port
    tarpit = {
      enable = mkEnableOption "Endlessh tarpit" // {default = cfg.port != 22;};
      port = mkOption {
        type = int;
        default = 22;
        apply = p:
          if (p != cfg.port)
          then p
          else if (p == 22)
          then 22
          else 21;
        description = ''
          Port opened to the endlessh server, 22 would be the most effective as a trap.
          Ensure this is not the same port opened for the real ssh server.
        '';
      };
    };

    port = mkOption {
      type = int;
      default = 30;
      description = ''
        Port opened to the ssh server.
      '';
    };
  };

  config = mkIf cfg.enable {
    # For helpful security diagnostics run
    # nix-shell -p ssh-audit --command "ssh-audit localhost:30"
    services = {
      openssh = {
        enable = true;
        openFirewall = true;
        ports = [cfg.port];
        #logLevel = "VERBOSE";

        startWhenNeeded = mkDefault true;

        settings = {
          PermitRootLogin = mkDefault "no";

          # Security
          PasswordAuthentication = false;
          AuthenticationMethods = "publickey";
          ChallengeResponseAuthentication = false;
          KbdInteractiveAuthentication = false;
          AllowStreamLocalForwarding = false;
          AllowTcpForwarding = "yes";
          X11Forwarding = false;

          PerSourceMaxStartups = 1;
          ClientAliveCountMax = 5;
          ClientAliveInterval = 60;
          MaxAuthTries = 7;

          KexAlgorithms = [
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group18-sha512"
            "diffie-hellman-group-exchange-sha256"
            "sntrup761x25519-sha512@openssh.com"
          ];

          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];

          /*
          Ciphers = [
            "aes256-gcn@openssh.com"
            "aes128-gcm@openssh.com"
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
          ];
          */
        };
      };
      endlessh = mkIf cfg.tarpit.enable {
        inherit (cfg.tarpit) port;
        openFirewall = true;
        extraOptions = ["-v" "-s"];
      };
    };
  };
}
