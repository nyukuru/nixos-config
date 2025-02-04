{
  pkgs, 
  ... 
}: {
  imports = [ 
    ./hardware-configuration.nix
    ./disk-config.nix

    ./modules
  ];
  
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [
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

  programs.nix-ld.enable = true;
  
  system.stateVersion = "24.05";
}

