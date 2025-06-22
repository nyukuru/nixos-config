{
  lib,
  inputs,
  withSystem,
  ...
}: let
  inherit (lib) nixosSystem;

  inherit
    (lib.attrsets)
    concatMapAttrs
    getAttrs
    ;

  inherit
    (lib.lists)
    optional
    map
    ;

  modules = inputs.self.nixosModules;

  mkModules = {
    form ? null,
    theme ? null,
    users ? [ "nyu" ],
    extraModules ? [],
    defaultModules ? [
      modules.common
      modules.services
      modules.system
      modules.programs
      modules.style
      modules.misc
    ],
  }: map (m: m.all or m) (
    defaultModules
    ++ extraModules
    ++ [{users.users = getAttrs users (import ../users.nix);}]
    ++ optional (form != null) (modules.forms.${form} or (throw "No such form ${form}!"))
    ++ optional (theme != null) (modules.themes.${theme} or (throw "No such theme ${theme}!"))
  );

  # nixosSystem wrapper that:
  # - overlays pkgs with all inputs packages (including self) 
  # - pass lib, inputs, and flake parts' inputs'
  mkNixosSystem = {
    system,
    hostname,
    modules ? [],
    specialArgs ? {},
  }:
    withSystem system (
      {inputs', ...}: nixosSystem {
        specialArgs = specialArgs // {
          inherit inputs lib;
          inherit inputs';
        };

        modules = modules ++ [{
          networking.hostName = hostname;
          nixpkgs.hostPlatform = system;
          nixpkgs.overlays = [
            # Consume packages from inputs
            (final: prev: concatMapAttrs (_: value: value.packages.${system} or {}) inputs)
          ];
        }];
      }
    );

in {
  inherit mkNixosSystem mkModules;
}
