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
    git-lfs
    nixpkgs-review
    gnumake
    gdb

    vlc
    gimp

    # Social
    fractal

    # Work
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

  system.stateVersion = "24.05";
}
