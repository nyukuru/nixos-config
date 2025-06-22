{
  description = "Nyu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dev-nixpkgs.url = "github:nyukuru/nixpkgs/init-dunst";
    dev-nixpkgs-waybar.url = "github:/nyukuru/nixpkgs/waybar-settings";

    # Preconfigured configs for specific devices
    # i.e laptops
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    # Break up the flake definition
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
    windex = {
      url = "path:/home/nyu/dev/windex";
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
      ];
    };
}
