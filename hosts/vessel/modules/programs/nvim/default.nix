{
  pkgs,
  packages,
  ...
}: {
  modules.programs.nvim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    configDir = "${./.}";

    plugins = {
      start = with pkgs.vimPlugins;
        [
          nvim-treesitter
          nvim-treesitter-parsers.nix
          nvim-treesitter-parsers.lua
          nvim-treesitter-parsers.python

          ## LSP Support
          nvim-lspconfig
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          cmp-treesitter
        ]
        ++ [packages.Base2Tone-nvim];

      opt = with pkgs.vimPlugins; [
      ];
    };
  };

  # Packages needed for this config
  environment.systemPackages = with pkgs; [
    lua-language-server
    basedpyright
    nil
  ];
}
