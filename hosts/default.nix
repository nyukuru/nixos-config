{inputs, ...}: let
  inherit (inputs.self.lib.builders) mkModules;

  mkNixosSystem = inputs.self.lib.builders.mkNixosSystem {
    usersFile = ./users.nix;
    hostsDir = ./.;
  };

  hw = inputs.nixos-hardware.nixosModules;
  disko = inputs.disko.nixosModules.default;
in {
  flake.nixosConfigurations = {
    vessel = mkNixosSystem {
      hostname = "vessel";
      system = "x86_64-linux";
      users = [
        "nyu"
      ];
      modules = mkModules {
        form = "laptop";
        theme = "eumyangu";
        extraModules = [
          hw.dell-xps-15-9520-nvidia
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
          users = [
            "nyu"
          ];
          modules = mkModules {
            form = "iso";
            theme = "eumyangu";
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
