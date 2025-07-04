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
    ;

  inherit
    (lib.fixedPoints)
    makeExtensible
    ;

  # Simple recursive update only two sets deep.
  libUpdate = recursiveUpdateUntil (path: _: _: (builtins.length path > 1));

  # Composed only of my own functions
  myLib = makeExtensible (final: let
    callLibs = module:
      import module (
        config._module.args
        // {
          inherit inputs;
          lib = libUpdate lib final;
        }
      );
  in {
    attrsets = callLibs ./attrsets.nix;
    builders = callLibs ./builders.nix;
    modules = callLibs ./modules.nix;
    files = callLibs ./files.nix;
    lists = callLibs ./lists.nix;
  });
in {
  # Export this flake's functions instead of all of nixpkgs.lib as well
  flake.lib = myLib;
}
