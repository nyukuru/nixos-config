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
  ];

  environment.pathsToLink = [ "/share"];

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

    vlc
    gimp

    # Social
    webcord
    fractal

    # Work
    jetbrains.pycharm-community-bin

    # Games
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
