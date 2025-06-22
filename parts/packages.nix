{
  lib,
  self,
  inputs,
  flake-parts-lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) concatMapAttrs;
  inherit (lib.filesystem) packagesFromDirectoryRecursive;

  inherit
    (lib.types)
    lazyAttrsOf
    package
    either
    ;

in {
  # Redefine flake-parts packages option to allow nested attrsets
  disabledModules = ["${inputs.flake-parts}/modules/packages.nix"];

  imports = [(flake-parts-lib.mkTransposedPerSystemModule {
    name = "packages";
    file = ./.;
    option = mkOption {
      type = let
        valueType = either package (lazyAttrsOf valueType);
      in valueType;
      default = { };
    };
  })];

  config = {
    perSystem = {inputs', system, ...}: let
      pkgs = inputs'.nixpkgs.legacyPackages;
    in {
      _module.args.pkgs = pkgs.extend self.overlays.default;

      packages = packagesFromDirectoryRecursive {
        directory = ../packages;
        callPackage = pkgs.newScope (
          concatMapAttrs (_: v:  v.packages.${system} or {})
          inputs
        );
      }; 
    };

    flake.overlays.default = (final: prev: self.packages.${final.system});
  };
}
