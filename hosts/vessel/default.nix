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
    openvpn
    git-crypt
    obsidian
    vlc
    gh

    gimp
    protonvpn-gui

    winetricks
    wineWowPackages.staging

    # Games
    lutris
    mangohud
    prismlauncher

    (inputs'.xivlauncher-rb.packages.xivlauncher-rb.override {
      useGameMode = true;
      nvngxPath = "${config.hardware.nvidia.package}/lib/nvidia/wine";
    })
  ];

  windex = {
    enable = true;
    cpu = "intel";

    vfio = {
      deviceIds = ["10de:25a2"];
    };
  };

  services.dunst = {
    package = pkgs.dunst.overrideAttrs {
      makeFlags = [
        "PREFIX=$(out)"
        "VERSION=$(version)"
        "SYSCONFDIR=$(out)/etc"
        "SYSCONFDIR=/etc/xdg"
        "SYSCONF_FORCE_NEW=0"
        "SERVICEDIR_DBUS=$(out)/share/dbus-1/services"
        "SERVICEDIR_SYSTEMD=$(out)/lib/systemd/user"
      ];
    };
  };

  system.stateVersion = "24.05";
}
