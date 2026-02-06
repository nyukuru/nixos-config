{pkgs, ...}: {
  imports = [
    ./disk-config.nix

    ./programs.nix
    ./system.nix
    ./services.nix
  ];

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # Utils
    unzip
    unrar
    zip
    rar

    openvpn
    filezilla
    obsidian
    gh
    git-crypt
    nixpkgs-review
    gnumake
    gdb

    vlc
    gimp

    # Social
    fractal

    # Work
    android-tools
    tmux
    jetbrains.pycharm
    jetbrains.rider

    # Classes
    ghidra
    bear
    chromium

    # Games
    godot
    blender
    lumafly
    archipelago
    protonplus
    bottles
    dolphin-emu
    wheelwizard

    flatpak
    ns-usbloader
    mangohud
    prismlauncher
  ];

  /*
  windex = {
    enable = true;
    cpu = "intel";

    vfio = {
      deviceIds = ["10de:25a2"];
    };
  };
  */

  system.stateVersion = "24.05";
}
