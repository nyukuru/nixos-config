{
  lib,
  ...
}: let
  inherit (lib.attrsets) attrNames attrValues mapAttrsToList getAttr isAttrs;
  inherit (lib.lists) head elem any filter;

  attrHead = x: getAttr (head (attrNames x)) x;
  # Inefficient but fine for now
  attrAny = pred: elem true (mapAttrsToList (_: pred));

  hasAttrRecursive = set: e:
    if set ? ${e} then true
    else any hasAttrRecursive (filter isAttrs (attrValues set));

in {
  inherit 
    attrHead
    attrAny
    hasAttrRecursive;
}
