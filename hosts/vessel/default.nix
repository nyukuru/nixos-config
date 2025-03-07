{
  inputs',
  inputs,
  config,
  pkgs,
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
    openvpn
    git-crypt
    obsidian
    vlc

    # Games
    lutris
    mangohud
    prismlauncher
    (inputs'.xivlauncher-rb.packages.xivlauncher-rb.override {
      useGameMode = true;
      nvngxPath = "${config.hardware.nvidia.package}/lib/nvidia/wine";
    })
  ];

  services.dunst = {
    enable = true;
  };

  system.stateVersion = "24.05";
}
