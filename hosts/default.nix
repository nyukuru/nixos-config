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
in {
  flake.nixosConfigurations = {
    vessel = mkNixosSystem {
      hostname = "vessel";
      system = "x86_64-linux";
      modules = mkModules {
        form = "laptop";
        style = "eumyangu";
        extraModules = [hw.dell-xps-15-9520-nvidia];
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
