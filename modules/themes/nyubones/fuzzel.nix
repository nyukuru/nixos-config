{config, ...}: let
  inherit (config.style) colors font;

  opaque = c: "${c}ff";
in {
  nyu.programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "${font.name}:pixelsize=14";
        prompt = ''""'';
        icons-enabled = false;
      };

      colors = {
        background = opaque colors.base0;
        text = "${colors.foreground}ee";
        input = "${colors.foreground}ee";
        placeholder = "${colors.base6}ee";

        match = opaque colors.baseA;

        selection = opaque colors.base8;
        selection-text = "${colors.foreground}ee";
        selection-match = opaque colors.baseA;

        border = opaque colors.base8;
      };

      border = {
        width = 4;
        radius = 4;
      };
    };
  };
}
