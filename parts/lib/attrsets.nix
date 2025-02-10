{
  lib,
  ...
}: let

  inherit 
    (lib.attrsets) 
    mapAttrsToList
    attrNames 
    getAttr
    ;

  inherit 
    (lib.lists) 
    head 
    elem
    ;


  attrHead = x: getAttr (head (attrNames x)) x;
  attrAny = pred: elem true (mapAttrsToList (_: pred));

in {
  inherit
    attrHead
    attrAny
    ;
}
