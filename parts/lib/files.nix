{lib, ...}: let
  inherit (lib.strings) readFile concatMapStringsSep;
  inherit (lib.lists) map;
  inherit (lib.attrsets) mapAttrs attrNames filterAttrs;

  # Provide functions reference outside of builtins
  readDir = builtins.readDir;
  baseNameOf = builtins.baseNameOf;

  filesIn = dir: (map
    (filename: dir + "/${filename}")
    (attrNames (readDir dir)));

  dirsIn = dir: (map
    (subdir: dir + "/${subdir}")
    (attrNames (
      filterAttrs
      (_: val: val == "directory")
      (readDir dir)
    )));

  concatMapFiles = list:
    concatMapStringsSep "\n" (x: readFile x) list;

  recursiveFileTree = dir:
    mapAttrs
    (n: v:
      if v == "directory"
      then recursiveFileTree (dir + "/${n}")
      else dir + "/${n}")
    (readDir dir);
in {
  inherit
    dirsIn
    filesIn
    readDir
    baseNameOf
    concatMapFiles
    recursiveFileTree
    ;
}
