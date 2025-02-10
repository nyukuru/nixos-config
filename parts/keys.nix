{
  lib,
  ...
}: let
  inherit
    (lib.attrsets)
    attrValues
    ;


  users = {
    nyoo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUkBh/UjIlQ1Oo9P2EwaIwcfzObJgaGe0LXZkIGXIEc";
  };

  machines = {
    vessel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUkBh/UjIlQ1Oo9P2EwaIwcfzObJgaGe0LXZkIGXIEc";
  };

in {
  flake.keys = {
    users = machines // {global = attrValues users;};
    machines = machines // {global = attrValues machines;};
  };
}
