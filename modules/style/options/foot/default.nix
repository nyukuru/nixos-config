{
  config,
  lib,
  ...
}: let
  
  inherit
    (lib.modules)
    mkIf;

  colors = config.style.colors;
in {
  config = mkIf config.programs.foot.enable {
    programs.foot.settings = {
      colors = {
        inherit 
	  (colors)
	  foreground
	  background
	  ;

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
