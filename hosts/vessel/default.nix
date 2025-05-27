{
  inputs',
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./disk-config.nix

    ./programs.nix
    ./system.nix
    ./services.nix

    ./users

    "${inputs.dev-nixpkgs}/nixos/modules/services/desktops/dunst.nix"
  ];

  environment.systemPackages = with pkgs; [
    # Utils
    unzip
    zip
    openvpn
    git-crypt
    filezilla
    obsidian
    vlc
    gh
    nixpkgs-review

    gimp
    protonvpn-gui

    winetricks
    wineWowPackages.staging

    # Work
    jetbrains.pycharm-community-bin

    # Games
    mangohud
    prismlauncher

    /*
    (inputs'.xivlauncher-rb.packages.xivlauncher-rb.override {
      useGameMode = true;
      nvngxPath = "${config.hardware.nvidia.package}/lib/nvidia/wine";
    })
    */
  ];

  windex = {
    enable = true;
    cpu = "intel";

    vfio = {
      deviceIds = ["10de:25a2"];
    };
  };

  system.stateVersion = "24.05";
}
