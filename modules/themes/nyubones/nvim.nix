{
  config,
  pkgs,
  ...
}: let
  inherit (config.style) colors;
in {
  nyu.programs.nvim = {
    plugins.start = [
      pkgs.vimPlugins.zenbones-nvim
      pkgs.vimPlugins.lush-nvim
    ];

    extra.lua = ''
      local colors_name = "nyubones"
      vim.g.colors_name = colors_name

      local lush = require "lush"
      local hsluv = lush.hsluv
      local util = require "zenbones.util"

      local bg = vim.o.background

      -- Override only the core Zenbones colors with our terminal palette.
      -- Everything else is filled in using Zenbones' normal palette.
      local palette = util.palette_extend({
        bg = hsluv "#${colors.base0}",
        fg = hsluv "#${colors.baseF}",

        rose = hsluv "#${colors.base1}",
        leaf = hsluv "#${colors.base2}",
        water = hsluv "#${colors.base4}",
      }, bg)

      -- Generate the normal Zenbones highlight specifications.
      local generator = require "zenbones.specs"
      local base_specs = generator.generate(
        palette,
        bg,
        generator.get_global_config(colors_name, bg)
      )

      -- Apply the generated Zenbones colorscheme.
      lush(base_specs)

      -- Keep terminal colors in sync with the same core palette.
      require("zenbones.term").apply_colors(palette)
    '';
  };
}
