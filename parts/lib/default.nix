{
  inputs,
  config,
  ...
}: let
  inherit (inputs.nixpkgs) lib;

  inherit (lib.fixedPoints) composeManyExtensions;
  inherit (lib.attrsets) recursiveUpdate;

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
      # Functions for file and directories
      files = callLibs ./files.nix;
      # Builders for systems
      builders = callLibs ./builders.nix;
      # Some helper functions for lists
      lists = callLibs ./lists.nix;
      # Helper functions for attrsets
      attrsets = callLibs ./attrsets.nix;
      # More helper functions...
      modules = callLibs ./modules.nix;
      # Agenix creation
      secrets = callLibs ./secrets.nix;
    };

  # Compose all imported libraries
  extensions = composeManyExtensions [
    myLib
    (_: _: inputs.flake-parts.lib)
  ];

  lib' = lib.extend extensions;
in {
  perSystem._module.args.lib = lib';
  _module.args.lib = lib';
  flake.lib = lib';
}
