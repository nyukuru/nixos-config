{
  description = "nyu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dev-nixpkgs.url = "github:nyukuru/nixpkgs/init-dunst";
    dev-nixpkgs-waybar.url = "github:/nyukuru/nixpkgs/waybar-settings";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    lanzaboote.url = "github:nix-community/lanzaboote";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
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
