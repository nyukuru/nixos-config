{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (self) lib;

    inherit (lib.builders) mkNixosSystem;
    inherit (lib.lists) concatLists flatten;

    hw = inputs.nixos-hardware.nixosModules;

    modules = self.nixosModules;
    # Option definitions and wrappers
    system = modules.system;
    programs = modules.programs;
    # Defines sane defaults
    common = modules.common;
    # Specification defaults for specific archetypes
    laptop = modules.forms.laptop;

    mkModules = {
      forms ? [],
      extraModules ? [],
    }:
      flatten (
        concatLists [
          [common system programs]
          forms
          extraModules
        ]
      );
  in {
    vessel = mkNixosSystem {
      hostname = "vessel";
      system = "x86_64-linux";
      modules = mkModules {
        forms = [laptop];
        extraModules = [hw.dell-xps-15-9520-nvidia];
      };
    };
  };
}
