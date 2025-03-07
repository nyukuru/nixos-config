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
	llvmPackages_19.clang-tools
	lua-language-server
	basedpyright
	nil
      ];
    })
  ];
}
