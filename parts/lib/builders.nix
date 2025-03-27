{
  inputs,
  withSystem,
  lib,
  ...
}: let
  inherit
    (lib)
    nixosSystem
    ;

  inherit
    (lib.lists)
    optional
    map
    ;

  # Helper function to take advantage of my nixosModules
  mkModules = let
    modules = inputs.self.nixosModules;
  in
    {
      form ? "",
      style ? "",
      extraModules ? [],
      defaultModules ? [
        modules.common
        modules.services
        modules.system
        modules.programs
        modules.style.options
      ],
    }:
    # Allows implicit absorbing of the whole branch
    # i.e system.all imports all branches in system.
    # this wont cause any conflicts because `all` is not a valid option.
      map (m: m.all or m) (
        defaultModules
        ++ extraModules
        ++ optional (form != "") (modules.forms.${form} or (throw "No such form ${form}!"))
        ++ optional (style != "") (modules.style.${style} or (throw "No such style/theme ${style}!"))
      );

  # NixosSystem wrapper that:
  # - uses flake-parts automatic insertion
  # - passes correct specialArgs
  # - automatically imports the starting point module
  mkNixosSystem = {
    system,
    hostname,
    modules ? [],
    specialArgs ? {},
  }:
    withSystem system (
      ctx:
        nixosSystem {

          specialArgs = {
            inherit
              hostname
              inputs
              lib
              ;

            inherit (ctx) inputs';
            inherit (ctx.self') packages;
          } // specialArgs;

          modules = [
            {
              imports = ["${inputs.self}/hosts/${hostname}"];
              networking.hostName = hostname;
              nixpkgs.hostPlatform = system;
            }
          ] ++ modules;
        }
    );

  # mkNixosSystem with added iso modules
  mkNixosIso = args:
    mkNixosSystem args
    // {
      modules =
        args.modules
        ++ [
          ({modulesPath, ...}: {
            imports = [
              (modulesPath + "/installer/cd-dvd/iso-image.nix")
              (modulesPath + "/installer/cd-dvd/channel.nix")
              (modulesPath + "/profiles/all-hardware.nix")
            ];
          })
        ];
    };
in {
  inherit
    mkNixosSystem
    mkNixosIso
    mkModules
    ;
}
