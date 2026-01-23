{pkgs, ...}: {
  imports = [
    ./disk-config.nix

    ./programs.nix
    ./system.nix
    ./services.nix
  ];

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
    vesktop

    # Work
    android-tools
    tmux

    # Classes
    #sage
    ghidra
    bear

    # Games
    godot
    blender
    lumafly
    archipelago

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
