{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ./users
    ./modules
  ];

  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps:
      with ps; [
        dbus-python
      ]))
    unzip
    openvpn
  ];

  boot = {
    extraModprobeConfig = ''
      options iwlwifi power_save=1 disable_11ax=1
    '';
  };

  services = {
    printing.enable = true;
    dbus.packages = with pkgs; [dconf gcr];
  };

  programs = {
    nix-ld.enable = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
	extraArgs = "--keep-since 3d --keep 5";
	dates = "Sun";
      };
    };
  };

  system.stateVersion = "24.05";
}
