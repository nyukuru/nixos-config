{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkDefault
    mkMerge
    mkIf
    ;

  cfg = config.nyu.programs.nvim;
in {
  config = mkMerge [
    {
      nyu.programs.nvim.configDir = mkDefault "${./.}";
    }

    (mkIf (cfg.enable && (cfg.configDir == "${./.}")) {
      nyu.programs.nvim = {
        plugins = {
          start = with pkgs.vimPlugins; [
            # Syntax Highlighting
            nvim-treesitter
            nvim-treesitter-parsers.nix
            nvim-treesitter-parsers.lua
            nvim-treesitter-parsers.python
            nvim-treesitter-parsers.meson
            nvim-treesitter-parsers.c
            nvim-treesitter-parsers.cpp

            # Navigation
            telescope-nvim
            harpoon2

            luasnip
            lualine-nvim

            # Lint
            vim-prettier
            vim-clang-format

            # LSP Support
            nvim-lspconfig
            nvim-cmp
            cmp-nvim-lsp
            cmp-buffer
            cmp-path
            cmp-git
            cmp-cmdline
            cmp-treesitter
          ];

          opt = with pkgs.vimPlugins; [
          ];
        };
      };

      # Packages needed for this config
      environment.systemPackages = with pkgs; [
        llvmPackages_21.clang-tools
        lua-language-server
        basedpyright
        nodePackages.prettier
        ripgrep
        nil
        typescript-language-server
        mesonlsp
      ];
    })
  ];
}
