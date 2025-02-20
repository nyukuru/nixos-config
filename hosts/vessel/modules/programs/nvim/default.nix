{pkgs, ...}: {
  modules.programs.nvim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    configDir = "${./.}";

    plugins = {
      start = with pkgs.vimPlugins; [
        # Syntax Highlighting
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
    lua-language-server
    # Waiting for unstable to merge build error fix
    basedpyright
    nil
  ];
}
