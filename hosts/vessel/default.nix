{
  inputs',
  config,
  pkgs,
  ...
}: {
  imports = [
    ./disk-config.nix

    ./programs.nix
    ./style.nix
    ./system.nix
    ./services.nix

    ./users
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

  system.stateVersion = "24.05";
}
