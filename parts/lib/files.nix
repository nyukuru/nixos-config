{lib, ...}: let
  inherit
    (lib.strings)
    concatMapStringsSep
    readFile
    ;

  inherit
    (lib.lists)
    map
    ;

  inherit
    (lib.attrsets)
    filterAttrs
    attrNames
    ;

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
in {
  inherit
    dirsIn
    filesIn
    readDir
    baseNameOf
    concatMapFiles
    ;
}
