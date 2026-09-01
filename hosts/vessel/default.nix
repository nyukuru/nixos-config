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
    git-lfs
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

    # Classes
    ghidra
    bear

    # Games
    godot
    ddnet

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
