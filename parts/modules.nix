{inputs, ...}: let
  inherit (inputs.self.lib.modules) mkModuleTree;
in {
  # Disable apply function which breaks set accessing
  disabledModules = ["${inputs.flake-parts}/modules/nixosModules.nix"];

  flake.nixosModules = mkModuleTree ../modules;
}
