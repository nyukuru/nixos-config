{
  pkgs,
  ...
}: {
  imports = [
    ./nvim.nix
    ./sway.nix
    ./dunst.nix
    ./waybar.nix
  ];

  style = {
    wallpaper = ./komeiji.png;

    # Base16 Black Metal
    colors = {
      background = "000000";
      foreground = "f8f8f6";

      base0 = "000000";
      base1 = "805e87";
      base2 = "dd9999";
      base3 = "a06666";
      base4 = "888888";
      base5 = "999999";
      base6 = "aaaaaa";
      base7 = "c1c1c1";

      base8 = "333333";
      base9 = "805e87";
      baseA = "dd9999";
      baseB = "a06666";
      baseC = "888888";
      baseD = "999999";
      baseE = "aaaaaa";
      baseF = "c1c1c1";
    };
  };

  nyufox.enable = true;

  gtk = {
    theme = {
      package = pkgs.kanagawa-gtk-theme;
      name = "Kanagawa-B";
    };
    iconTheme = {
      package = pkgs.kanagawa-icon-theme;
      name = "Kanagawa";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
