{
  config,
  lib,
  ...
}: let
  inherit (config.style) font colors;
in {
  programs = {
    git = {
      enable = true;
      config.init.defaultBranch = "main";
    };

    nix-ld.enable = true;

    nh = {
      enable = true;
      flake = "/home/nyu/nixos-config";
      clean = {
        enable = true;
        extraArgs = "--keep-since 3d --keep 5";
        dates = "Sun";
      };
    };

    foot.settings = {
      main = {
        font = "monospace:size=${toString font.size}";
        pad = "4x4";
      };

      colors-dark = {
        background = colors.base0;
        foreground = colors.base7;

        regular0 = colors.base0;
        regular1 = colors.base1;
        regular2 = colors.base2;
        regular3 = colors.base3;
        regular4 = colors.base4;
        regular5 = colors.base5;
        regular6 = colors.base6;
        regular7 = colors.base7;

        bright0 = colors.base8;
        bright1 = colors.base9;
        bright2 = colors.baseA;
        bright3 = colors.baseB;
        bright4 = colors.baseC;
        bright5 = colors.baseD;
        bright6 = colors.baseE;
        bright7 = colors.baseF;
      };
    };
  };
}
