{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault;

in { 
  fonts = {
    packages = with pkgs; [
      material-icons
      corefonts
      twemoji-color-font
      noto-fonts
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = mkDefault rec {
        emoji = ["Twitter Color Emoji" "Material Icons Sharp"];
        monospace = ["JetBrainsMono Nerd Font Mono"] ++ emoji;
	sansSerif = ["JetBrainsMono Nerd Font Mono"] ++ emoji; 
	serif = ["Noto Serif"] ++ emoji; 
      };
    };
  };


  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline8x16.psf";
    packages = [pkgs.tamzen];
  };
}
