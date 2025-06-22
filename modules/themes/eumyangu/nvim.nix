{
  config,
  pkgs,
  ...
}: let
  inherit (config.style) colors;
in {
  nyu.programs.nvim = {
    plugins.start = [pkgs.vimPlugins.lackluster-nvim];

    extra.lua = ''
      local lackluster = require('lackluster')
      local color = lackluster.color

      lackluster.setup({
        tweak_color = {
          luster = "#${colors.base3}",
          lack = "#${colors.base2}",

          -- TODO: these default colors are too harsh
          orange = "default",
          yellow = "default",
          green = "default",
          blue = "default",
          red = "default",
        },

        tweak_background = {
          normal = "#${colors.base0}",
        },

        -- Replace undercurl with underlines
        tweak_ui = {
          disable_undercurl = true
        },
      })

      vim.cmd.set("termguicolors")
      vim.cmd.colorscheme("lackluster")
    '';
  };
}
