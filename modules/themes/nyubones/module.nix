{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./nvim.nix
    ./sway.nix
    ./niri.nix
    ./dunst.nix
    ./waybar.nix
  ];

  style = {
    wallpaper = ./sailor.png;

    colors = {
      background = "1C1917";
      foreground = "E8E5DF";

      base0 = "1C1917";
      base1 = "D88991"; 
      base2 = "8FA77A"; 
      base3 = "6F6A64"; 
      base4 = "7F9FB5"; 
      base5 = "8A827B"; 
      base6 = "A49C94"; 
      base7 = "C8C4BE"; 

      base8 = "332F2C"; 
      base9 = "E39AA1"; 
      baseA = "A6BD8E"; 
      baseB = "8D8780"; 
      baseC = "94B2C6"; 
      baseD = "AAA39B"; 
      baseE = "C1BBB4"; 
      baseF = "E8E5DF"; 
    };
  };

  nyufox.enable = true;

  gtk = {
    /*
    theme = {
      package = eumangyu-gtk;
      name = "Eumangyu";
    };
    */

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
