{
  lib,
  ...
}: let

  inherit 
    (lib.lists)
    mutuallyExclusive
    ;

  inherit 
    (lib.trivial) 
    warn
    ;

  mutuallyInclusive = x: y: !mutuallyExclusive x y;

  optionalsWarn = cond: msg: x:
    if cond then
      warn msg []
    else x;

in {
  inherit 
    mutuallyInclusive 
    optionalsWarn
    ;
}
