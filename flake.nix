{
  description = "Nyu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dev-nixpkgs.url = "git+file:///home/nyoo/dev/nixpkgs";

    # Preconfigured configs for specific devices
    # most useful for the pci information.
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    # Make flakes work with system.
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Secret manager
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tree formatter for flake-parts.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declaratively define disk partitions.
    # Handy for reinstalls especially with encrypted drives.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure boot for NixOS.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Windows vm easy setup
    wfvm = {
      url = "git+https://git.m-labs.hk/m-labs/wfvm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # XIV launcher with some patches to work better i.e DLSS
    xivlauncher-rb = {
      url = "github:drakon64/nixos-xivlauncher-rb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./hosts
        ./parts
        ./packages
      ];
    };
}
