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

  modules' = inputs.self.nixosModules;

  mkModules = {
    form ? null,
    style ? null,
    entry ? null,
    extraModules ? [],
    defaultModules ? [
      modules'.common
      modules'.services
      modules'.system
      modules'.programs
      modules'.style.options
    ],
  }:
  # Allows implicit absorbing of the whole branch
  # i.e system.all imports all branches in system.
    map (m: m.all or m) (
      defaultModules
      ++ extraModules
      ++ optional (entry != null) entry
      ++ optional (form != null) (modules'.forms.${form} or (throw "No such form ${form}!"))
      ++ optional (style != null) (modules'.style.${style} or (throw "No such style/theme ${style}!"))
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
          specialArgs = specialArgs // {
            inherit inputs lib;
            inherit (ctx) inputs';
            inherit (ctx.self') packages;
          };

          modules = modules ++ [{
            networking.hostName = hostname;
            nixpkgs.hostPlatform = system;
          }];
        }
    );

in {
  inherit
    mkNixosSystem
    mkModules
    ;
}
