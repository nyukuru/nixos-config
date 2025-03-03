{packages, ...}: {
  nyu.programs.nvim = {
    plugins.start = [packages.lackluster-nvim];

    extra.lua = ''
           local lackluster = require('lackluster')
           local color = lackluster.color

           lackluster.setup({
             tweak_color = {
        luster = "#f3d9ea",
        lack = "#90707e",

        -- TODO: these default colors are too harsh
        orange = "default",
        yellow = "default",
        green = "default",
        blue = "default",
        red = "default",

        -- Brown shift the monochrome colors
        black = "default",
        gray1 = "#16130f",
        gray2 = "#1d1816",
        gray3 = "#2f2623",
        gray4 = "#4e403b",
        gray5 = "#604E48",
        gray6 = "#8C7169",
        gray7 = "#b7a59f",
        gray8 = "#d3c8c5",
        gray9 = "#e2dbd9",
      },

      tweak_background = {
        normal = color.gray1
        -- Second background: #342d24
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
