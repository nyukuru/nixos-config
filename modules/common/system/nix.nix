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

  GB = x: toString (x * 1024 * 1024 * 1024);
in {
  nixpkgs.config = {
    allowUnfree = mkForce true;
    allowBroken = mkDefault false;
    #enableParallelBuildingByDefault = true;
  };

  documentation = {
    enable = mkDefault true;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
    nixos.enable = mkDefault false;
    man.enable = mkDefault true;
  };

  nix = {
    package = mkDefault pkgs.lix;
    daemonCPUSchedPolicy = mkDefault "idle";
    daemonIOSchedClass = mkDefault "idle";

    # Store Optimizer
    optimise = {
      automatic = mkDefault true;
      dates = mkDefault ["Tue,Thu,Sat"];
    };

    settings = {
      # https://nix.dev/manual/nix/2.18/command-ref/conf-file.html
      auto-optimise-store = mkDefault true;
      stalled-download-timeout = mkDefault 30;
      connect-timeout = mkDefault 10;
      allowed-users = ["root" "@wheel"];
      trusted-users = ["root" "@wheel"];

      # Free 5GB when less than 1GB is left.
      min-free = mkDefault (GB 1);
      max-free = mkDefault (GB 5);

      # Isolate builds, stop if something prevents that.
      sandbox = mkDefault true;
      sandbox-fallback = mkDefault false;

      # Gives some extra lines to the tail of log
      log-lines = mkDefault 20;

      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
        "no-url-literals"
      ];

      pure-eval = mkDefault false;
      warn-dirty = mkDefault false;
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
