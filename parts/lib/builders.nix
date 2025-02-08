{
  inputs,
  withSystem,
  lib,
  ...
}: let
  inherit (lib) nixosSystem;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.lists) map;

  # TODO clean this.
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
            ++ map (n: n.all or n) modules;
        }
    );
in {
  inherit mkNixosSystem;
}
