{pkgs, lib, ...}: let
  inherit (lib.meta) getExe;

in {
  environment.shellAliases = {
    # How can we eliminate this absolute path?
    nr = "nix-store --verify; pushd /home/nyoo/nixos-config; ${getExe pkgs.nh} os switch .; popd"; 
  };
}
