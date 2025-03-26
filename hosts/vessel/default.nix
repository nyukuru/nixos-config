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

    jetbrains.pycharm-community-bin

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

    enable = true;

    settings = {
      urgency_normal = {
        background = lib.mkForce "#000000";
      };
    };
  };

  system.stateVersion = "24.05";
}
