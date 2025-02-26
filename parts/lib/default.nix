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
    (lib.fixedPoints)
    composeManyExtensions
    ;

  inherit
    (lib.attrsets)
    recursiveUpdate
    ;

  # An overlay of my library to go onto nixpkgs'
  myLib = final: prev: let
    callLibs = module:
      import module (config._module.args
        // {
          inherit inputs;
          lib = final;
        });
  in
    recursiveUpdate prev {
      files = callLibs ./files.nix;
      builders = callLibs ./builders.nix;
      lists = callLibs ./lists.nix;
      attrsets = callLibs ./attrsets.nix;
      modules = callLibs ./modules.nix;
      secrets = callLibs ./secrets.nix;
    };

  # Compose all imported libraries
  extensions = composeManyExtensions [
    myLib
    (_: _: inputs.flake-parts.lib)
    (_: _: inputs.wfvm.lib)
  ];

  lib' = lib.extend extensions;
in {
  perSystem._module.args.lib = lib';
  _module.args.lib = lib';
  flake.lib = lib';
}
