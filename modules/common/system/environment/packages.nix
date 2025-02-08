{pkgs, lib, ...}: let
  inherit (lib.modules) mkForce;

in {
  environment = {
    # Remove unneded default packages.
    defaultPackages = mkForce [];

    systemPackages = with pkgs; [
      # Network transfers.
      curl
      wget
      rsync
      git
      cifs-utils

      # Text editor.
      vim 
    ];
  };
}
