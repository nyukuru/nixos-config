{
  inputs,
  ...
}: let

  inherit
    (inputs.self)
    lib
    ;

  inherit
    (lib.builders)
    mkNixosSystem
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
  };
}
