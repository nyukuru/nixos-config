{lib, ...}: let
  inherit
    (lib.modules)
    mkOptionDefault
    mkDefault
    mkForce
    ;

  inherit
    (lib.attrsets)
    mapAttrsRecursive
    filterAttrs
    attrNames
    ;

  inherit
    (lib.lists)
    foldl
    ;

  inherit
    (lib.files)
    readDir
    ;

  mkForceAttr = mapAttrsRecursive (_: v: mkForce v);
  mkDefaultAttr = mapAttrsRecursive (_: v: mkDefault v);
  mkOptionDefaultAttr = mapAttrsRecursive (_: v: mkOptionDefault v);

  # Create an attrset tree representing the filestructure of a modules folder,
  # Leafs are module.nix files
  mkModuleTree = path: let
    allFiles = readDir path;
    dirFiles = attrNames (filterAttrs (_: v: v == "directory") allFiles);
  in
    # Leaf case
    if allFiles ? "module.nix"
    then {imports = [(path + "/module.nix")];}
    # Branch/Directory case
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
  inherit
    mkForceAttr
    mkDefaultAttr
    mkOptionDefaultAttr
    mkModuleTree
    ;
}
