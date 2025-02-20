{
  imports = [
    ./nvim.nix
    ./sway.nix
    ./dunst.nix
  ];

  modules.style = {
    colors = {
      base0 = "16130f";
      base1 = "85544b";
      base2 = "7e7b57";
      base3 = "8b624b";
      base4 = "926579";
      base5 = "795d8a";
      base6 = "87776a";
      base7 = "b7a59f";
      base8 = "4e403b";
      base9 = "c6827d";
      baseA = "b0aa91";
      baseB = "b28d77";
      baseC = "c297aa";
      baseD = "aa97b7";
      baseE = "c8b7aa";
      baseF = "e2dbd9";
    };
    nyufox = {
      enable = true;
      
      border = {
        width = 2;
	rounding = 5;
      };
    };
  };
}
