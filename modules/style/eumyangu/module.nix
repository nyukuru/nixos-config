{
  imports = [
    ./nvim.nix
    ./sway.nix
    ./dunst.nix
    ./waybar.nix
  ];

  style = {
    wallpaper = ./komeiji.png;

    colors = {
      background = "000000";
      foreground = "f8f8f6";

      base0 = "232a2d";
      base1 = "e57474";
      base2 = "57553c";
      base3 = "8ccf7e";
      base4 = "67b0e8";
      base5 = "c47fd5";
      base6 = "6cbfbf";
      base7 = "b3b9b8";

      base8 = "2d3437";
      base9 = "ef7e7e";
      baseA = "96d988";
      baseB = "f4d67a";
      baseC = "71baf2";
      baseD = "ce89df";
      baseE = "67cbe7";
      baseF = "bdc3c2";
    };

    nyufox = {
      enable = true;

      color = {
        background = "#000000";
        border = "#29292d";
      };

      border = {
        width = 2;
        rounding = 5;
      };
    };
  };

  programs.foot.settings = {
    main = {
      font = "monospace:size=10";
    };
  };
}
