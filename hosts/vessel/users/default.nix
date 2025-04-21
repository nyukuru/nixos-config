{
  imports = [
    ./nyu.nix
  ];

  users.extraGroups = {
    # Rights to the media drive
    media = {};
  };
}
