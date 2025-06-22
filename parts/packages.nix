{
  lib,
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

  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "packages";
      file = ./.;
      option = mkOption {
        type = let
          valueType = either package (lazyAttrsOf valueType);
        in
          valueType;
        default = {};
      };
    })
  ];

  config = {
    perSystem = {
      inputs',
      config,
      ...
    }: let
      pkgs = inputs'.nixpkgs.legacyPackages;
    in {
      overlayAttrs = config.packages;

      packages = packagesFromDirectoryRecursive {
        directory = ../packages;
        callPackage = pkgs.newScope (
          concatMapAttrs (_: v: v.packages.${pkgs.system} or {})
          (removeAttrs inputs ["self"])
        );
      };
    };
  };
}
