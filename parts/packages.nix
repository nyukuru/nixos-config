{
  inputs,
  lib,
  ...
}: let
  flake-parts-lib = inputs.flake-parts.lib;

  inherit
    (lib.options)
    mkOption
    ;
  inherit
    (lib.types)
    lazyAttrsOf
    package
    either
    ;

in {
  disabledModules = ["${inputs.flake-parts}/modules/packages.nix"];

  # This is pretty bad because traversing packages will give recursion errors
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

  perSystem = {pkgs, inputs', ...}: {
    packages = pkgs.lib.packagesFromDirectoryRecursive {
      # This is the equivalent of callPackage and just injects inputs,
      # eventually I'd like to expose just the packages supplied by the inputs
      # directly, but unsure atm and inputs may be a good way to indicate source anyway
      callPackage = pkgs.newScope {inputs = inputs';};
      inherit (pkgs) newScope;
      directory = ../packages;
    };
  };
}
