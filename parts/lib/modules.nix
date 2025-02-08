{lib, ...}: let
  inherit (lib.modules) mkForce mkDefault mkOptionDefault;
  inherit (lib.attrsets) mapAttrsRecursive;

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
