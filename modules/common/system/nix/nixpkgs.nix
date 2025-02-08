{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkDefault mkForce;
in {
  nixpkgs = {
    config = {
      # It's better to be alerted when an installed package
      # or a package attempting to be installed has been deliberartely
      # marked as broken. Manual steps should then be taken to fix the breakage.
      #allowBroken = mkDefault false;

      # Needed for some things to work.
      allowUnfree = mkForce true;

      # Speed up of most package builds
      # TODO fix...
      enableParallelBuildingByDefault = false;
    };
  };
}
