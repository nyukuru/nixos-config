{
  inputs,
  config,
  ...
}: let

  inherit
    (inputs.nixpkgs)
    lib
    ;

  inherit
    (lib.attrsets)
    recursiveUpdateUntil
    recursiveUpdate
    ;

  inherit
    (lib.fixedPoints)
    makeExtensible
    ;

  # Simple recursive update only two sets deep.
  libUpdate = recursiveUpdateUntil (path: _: _: (builtins.length path > 1));

  # Composed only of my own functions
  myLib = makeExtensible (final: let
    callLibs = module: import module (
      config._module.args // {
        inherit inputs;
	lib = libUpdate lib final;
      });
  in {
    attrsets = callLibs ./attrsets.nix;
    builders = callLibs ./builders.nix;
    modules  = callLibs ./modules.nix;
    files    = callLibs ./files.nix;
    lists    = callLibs ./lists.nix;
  });

  # An overlay of my library to go onto nixpkgs'
  myLibOverlay = final: prev: 
    libUpdate prev myLib;

  lib' = lib.extend myLibOverlay;
in {
  perSystem._module.args.lib = lib';
  _module.args.lib = lib';

  # Export this flake's functions instead of all of nixpkgs.lib as well
  flake.lib = myLib;
}
