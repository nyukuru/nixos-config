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
    (lib.attrsets)
    recursiveUpdate
    ;

  inherit
    (lib.lists)
    optionals
    optional
    map
    ;

  mkModules = {
    form ? "",
    style ? "",
    defaultModules ? true,
    extraModules ? [],
  }: let
    modules = inputs.self.nixosModules;
  in
    # Allows implicit absorbing of my own module system
    map (m: m.all or m) (
      extraModules
      ++ optional (form != "") (modules.forms.${form} or (throw "No such form ${form}!"))
      ++ optional (style != "") (modules.style.${style} or (throw "No such style/theme ${style}!"))
      ++ optionals defaultModules [
        modules.common
        modules.system
        modules.programs
        modules.style.options
      ]
    );

  mkNixosSystem = {
    system,
    hostname,
    modules ? [],
    specialArgs ? {},
  }:
    withSystem system (
      ctx:
        nixosSystem {
          inherit lib;

          specialArgs =
            recursiveUpdate {
              inherit inputs hostname;
              inherit (ctx) inputs';
              inherit (ctx.self') packages;
            }
            specialArgs;

          modules =
            [
              {
                imports = ["${inputs.self.outPath}/hosts/${hostname}"];
                networking.hostName = hostname;
                nixpkgs.hostPlatform = system;
              }
            ]
            ++ modules;
        }
    );
in {
  inherit
    mkNixosSystem
    mkModules
    ;
}
