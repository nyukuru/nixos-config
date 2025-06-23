{
  inputs,
  lib,
  ...
}: let
  inherit (inputs.self.lib.modules) mkModuleTree;

  inherit
    (lib.lists)
    subtractLists
    concatLists
    ;

  modulesTree = mkModuleTree ../modules;

  without = modules:
    subtractLists
    (concatLists (map (module: modulesTree.${module}.all.imports) modules))
    modulesTree.all.imports;
in {
  # Disable apply function which breaks set accessing
  disabledModules = ["${inputs.flake-parts}/modules/nixosModules.nix"];

  flake.nixosModules =
    modulesTree
    // {
      default = {
        imports = without [
          "themes"
          "forms"
        ];
      };
    };
}
