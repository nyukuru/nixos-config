{
  imports = [
    ./nyu.nix
    ./nyoo.nix
  ];

  users.extraGroups = {
    # Rights to the media drive
    media = {};
  };
}
