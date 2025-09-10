{
  lib,
  inputs,
  withSystem,
  ...
}: let
  inherit (lib) nixosSystem;
  inherit (lib.trivial) pathExists;

  inherit
    (lib.attrsets)
    recursiveUpdate
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
    extraModules ? [],
    defaultModules ? [
      modules.default
    ],
  }:
    map (m: m.all or m) (
      defaultModules
      ++ extraModules
      ++ optional (form != null) (modules.forms.${form} or (throw "No such form ${form}!"))
      ++ optional (theme != null) (modules.themes.${theme} or (throw "No such theme ${theme}!"))
    );

  # nixosSystem wrapper that:
  # - overlays pkgs with all inputs packages (including self)
  # - pass lib, inputs, and flake parts' inputs'
  mkNixosSystem = {
    usersFile,
    hostsDir,
  }: {
    system,
    hostname,
    users ? [],
    modules ? [],
    subsumedFlakes ? ["self"],
    specialArgs ? {},
  }:
    withSystem system (
      {inputs', ...}:
        nixosSystem {
          specialArgs =
            specialArgs
            // {
              inherit inputs lib;
              inherit inputs';
            };

          modules =
            modules
            ++ (optional (pathExists "${hostsDir}/${hostname}") "${hostsDir}/${hostname}")
            ++ [
              {
                networking.hostName = hostname;
                nixpkgs.hostPlatform = system;
                nixpkgs.overlays = [(final: prev: concatMapAttrs (_: v: recursiveUpdate prev v.packages.${system}) (getAttrs subsumedFlakes inputs))];
                users.users = getAttrs users (import usersFile);
                assertions = [
                  {
                    assertion = users != [];
                    message = "No users defined in top level mkNixosSystem!";
                  }
                ];
              }
            ];
        }
    );
in {
  inherit mkNixosSystem mkModules;
}
