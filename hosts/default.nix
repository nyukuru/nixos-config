{inputs, ...}: let
  inherit
    (inputs.self)
    lib
    ;

  inherit
    (lib.builders)
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
        entry = ./vessel;
        form = "laptop";
        style = "eumyangu";
        extraModules = [
          ./users

          hw.dell-xps-15-9520-nvidia
          dunst
          disko
          windex
        ];
      };
    };
  };

  perSystem = {
    packages = {
      carbon-iso = (mkNixosSystem {
        hostname = "carbon";
        system = "x86_64-linux";
        modules = mkModules {
          entry = ./carbon;
          form = "iso";
          style = "eumyangu";
          extraModules = [
            ./users

            dunst
          ];
        };
      }).config.system.build.image;

      argon-iso = (mkNixosIso {
        hostname = "argon";
        system = "x86_64-linux";
        modules = mkModules {
          defaultModules = [];
        };
      }).config.system.build.image;
    };
  };
}
