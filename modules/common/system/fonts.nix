{
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkDefault
    ;

in {
  fonts = {
    packages = with pkgs; [
      # Typical fonts
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      # Symbol fonts
      nerd-fonts.symbols-only
      twemoji-color-font
      material-icons

      # Programming fonts
      jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = mkDefault rec {
        emoji = ["Twitter Color Emoji" "Symbols Nerd Font" "Material Icons Sharp"];
        monospace = ["JetBrains Mono" "Noto Sans Mono"] ++ emoji;
        sansSerif = ["JetBrains Mono" "Noto Sans"] ++ emoji;
        serif = ["Noto Serif"] ++ emoji;
      };
    };
  };

  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline8x16.psf";
    packages = [pkgs.tamzen];
  };
}
