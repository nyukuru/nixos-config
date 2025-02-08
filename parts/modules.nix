{
  lib,
  inputs,
  ...
}: let
  inherit
    (lib.attrsets)
    attrNames
    filterAttrs
    ;

  inherit
    (lib.lists)
    foldl
    ;

  inherit
    (builtins)
    readDir
    ;

  mkModuleTree = path: let
    allFiles = readDir path;
    dirFiles = attrNames (filterAttrs (_: v: v == "directory") allFiles);
  in
    # End branch when a module file is found
    # There shouldn't be multiple module files sharing a parent folder
    if allFiles ? "module.nix"
    then {imports = [(path + "/module.nix")];}
    # Directory case
    else
      foldl (
        acc: file: let
          result = mkModuleTree (path + "/${file}");
        in
          # Branch(s) with module leaf
          if (result != {})
          then
            acc
            // {
              ${file} = result;
              all.imports = (acc.all.imports or []) ++ (result.imports or result.all.imports);
            }
          # Branch with no module file
          else acc
      ) {}
      dirFiles;
in {
  # Disable apply function which breaks set accessing
  disabledModules = ["${inputs.flake-parts.outPath}/modules/nixosModules.nix"];

  flake.nixosModules = mkModuleTree ../modules;
}
