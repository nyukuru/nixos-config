{inputs, ...}: let

  inherit
    (inputs.self)
    lib
    ;

  inherit
    (lib.modules)
    mkModuleTree
    ;

in {
  # Disable apply function which breaks set accessing
  disabledModules = ["${inputs.flake-parts.outPath}/modules/nixosModules.nix"];

  flake.nixosModules = mkModuleTree ../modules;
}
