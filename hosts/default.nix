{
  inputs,
  self,
  ...
}: let 

  inherit 
    (self) 
    lib;

  inherit 
    (lib.builders) 
    mkNixosSystem;

  inherit 
    (lib.lists)
    map;

  hw = inputs.nixos-hardware.nixosModules;

  modules = self.nixosModules;
  # Default modules
  system = modules.system;
  programs = modules.programs;
  common = modules.common;
  style = modules.style.options;

  # Forms
  laptop = modules.forms.laptop;

  mkModules = {
    form ? {},
    extraModules ? [],
  }:
    map (m: m.all or m) (
      extraModules
      ++ [
	common
	system
	programs
	style
	form
      ]);
	
in {
  flake.nixosConfigurations = {

    vessel = mkNixosSystem {
      hostname = "vessel";
      system = "x86_64-linux";
      modules = mkModules {
        form = laptop;
        extraModules = [hw.dell-xps-15-9520-nvidia];
      };
    };
  };
}
