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
    ;

  mkForceAttr = mapAttrsRecursive (_: v: mkForce v);
  mkDefaultAttr = mapAttrsRecursive (_: v: mkDefault v);
  mkOptionDefaultAttr = mapAttrsRecursive (_: v: mkOptionDefault v);
in {
  inherit
    mkForceAttr
    mkDefaultAttr
    mkOptionDefaultAttr
    ;
}
