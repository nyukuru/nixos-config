{lib, ...}: let
  inherit (lib.modules) mkDefault;

in {
  programs.nh = {
    enable = mkDefault true;
    clean = {
      enable = mkDefault true;
      extraArgs = mkDefault "--keep-since 5d --keep 5";
      dates = mkDefault "Sun";
    };
  };
}
