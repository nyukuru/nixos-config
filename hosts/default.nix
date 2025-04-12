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
        style = "eumyangu";
        extraModules = [
          hw.dell-xps-15-9520-nvidia
          disko
          windex
        ];
      };
    };

    tantalum = mkNixosIso {
      hostname = "tantalum";
      system = "x86_64-linux";
      modules = mkModules {
        defaultModules = [];
      };
    };

    argon = mkNixosIso {
      hostname = "argon";
      system = "x86_64-linux";
      modules = mkModules {
        defaultModules = [];
      };
    };
  };
}
