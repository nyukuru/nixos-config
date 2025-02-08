{
  description = "Nyu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Preconfigured configs for specific devices
    # most useful for the pci information.
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    # Self-explanatory.
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    # Make flakes work with system.
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    textfox = {
      url = "/home/nyoo/dev/textfox";
      inputs.nixpkgs.follows = "nixpkgs";
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
