let
  users = {
    nyoo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUkBh/UjIlQ1Oo9P2EwaIwcfzObJgaGe0LXZkIGXIEc";
  };

  machines = {
    vessel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUkBh/UjIlQ1Oo9P2EwaIwcfzObJgaGe0LXZkIGXIEc";
  };
in {
  users = machines // {global = builtins.attrValues users;};
  machines = machines // {global = builtins.attrValues machines;};
}
