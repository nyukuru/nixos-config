{inputs, ...}: let
  inherit
    (inputs.self.lib.builders)
    mkNixosSystem
    mkNixosIso
    mkModules
    ;

  dunst = "${inputs.dev-nixpkgs}/nixos/modules/services/desktops/dunst.nix";

  hw = inputs.nixos-hardware.nixosModules;
  disko = inputs.disko.nixosModules.default;
  windex = inputs.windex.nixosModules.default;
in {
  flake.nixosConfigurations = {
    vessel = mkNixosSystem {
      hostname = "vessel";
      system = "x86_64-linux";
      modules = mkModules {
        form = "laptop";
        theme = "eumyangu";
        extraModules = [
          ./vessel
          hw.dell-xps-15-9520-nvidia
          dunst
          disko
          #windex
        ];
      };
    };
  };

  perSystem = {system, ...}: {
    packages = {
      carbon-iso =
        (mkNixosSystem {
          hostname = "carbon";
          system = system;
          modules = mkModules {
            form = "iso";
            theme = "eumyangu";
            extraModules = [
              ./carbon
              dunst
            ];
          };
        }).config.system.build.image;

      /*
      argon-iso =
        (mkNixosSystem {
          hostname = "argon";
          system = system;
          modules = mkModules {
            defaultModules = [];
          };
        }).config.system.build.image;
      */
    };
  };
}
