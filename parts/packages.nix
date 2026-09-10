{
  lib,
  inputs,
  flake-parts-lib,
  ...
}: let
  inherit (lib.options) mkOption mergeOneOption;
  inherit (lib.attrsets) concatMapAttrs;
  inherit (lib.filesystem) packagesFromDirectoryRecursive;

  inherit
    (lib.types)
    mkOptionType
    lazyAttrsOf
    package
    either
    ;

  functorPackage = mkOptionType {
    name = "functorPackage";
    description = "callable package";
    check = x: builtins.isAttrs x && x ? __functor;
    merge = loc: defs: mergeOneOption loc defs;
  };
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
          valueType =
            (either package (either functorPackage (lazyAttrsOf valueType)))
            // {
              description = "package, callable package, or nested attribute set of packages";
            };
        in
          valueType;
        default = {};
      };
    })
  ];

  config.perSystem = {
    pkgs,
    config,
    system,
    ...
  }: {
    overlayAttrs = config.packages;

    packages = packagesFromDirectoryRecursive {
      directory = ../packages;
      callPackage = pkgs.newScope (
        concatMapAttrs (_: v: v.packages.${system} or {}) inputs
      );
    };
  };
}
