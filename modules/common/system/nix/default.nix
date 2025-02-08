{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault;
  inherit (lib.attrsets) mapAttrsToList;
in {
  imports = [
    # Nixpkgs option defaults
    ./nixpkgs.nix
    # Nix documentation defaults
    ./documentation.nix
    # Nix helper cli tool
    ./nh.nix
  ];

  nix = let
    GB = x: toString (x * 1024 * 1024 * 1024);
  in {
    package = mkDefault pkgs.lix;

    daemonCPUSchedPolicy = mkDefault "idle";
    daemonIOSchedClass = mkDefault "idle";
    daemonIOSchedPriority = mkDefault 7;

    # Store Optimizer
    optimise = {
      automatic = mkDefault true;
      # Tuesday, Thursday, Saturday
      dates = mkDefault ["Tue,Thu,Sat"];
    };

    settings = {
      # https://nix.dev/manual/nix/2.18/command-ref/conf-file.html

      auto-optimise-store = mkDefault true;

      # Restarts download after 30 seconds of no contact.
      stalled-download-timeout = mkDefault 30;

      # The curl connection timeout, let us know if we have no internet.
      connect-timeout = mkDefault 10;

      allowed-users = ["root" "@wheel"];
      trusted-users = ["root" "@wheel"];

      # Free 5GB when less than 1GB is left.
      min-free = mkDefault (GB 1);
      max-free = mkDefault (GB 5);

      # Isolate builds, stop if something prevents that.
      sandbox = mkDefault true;
      sandbox-fallback = mkDefault false;

      max-jobs = mkDefault 7;
      cores = mkDefault 4;

      # Gives some extra lines to the tail of log
      log-lines = mkDefault 20;

      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
        "no-url-literals"
      ];

      # Complete declaritive purity.
      #pure-eval = true;

      warn-dirty = mkDefault false;

      # Alert if a third party is changing the config.
      accept-flake-config = mkDefault false;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];
    };
  };
}
