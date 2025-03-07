{pkgs, ...}: let
  inherit
    (pkgs)
    fetchFromGitHub
    ;

  inherit
    (pkgs.vimUtils)
    buildVimPlugin
    ;
in {
  packages = {
    lackluster-nvim = buildVimPlugin {
      pname = "lackluster.nvim";
      version = "2024-12-29";
      src = fetchFromGitHub {
        owner = "slugbyte";
        repo = "lackluster.nvim";
        rev = "662fba7e6719b7afc155076385c00d79290bc347";
        sha256 = "sha256-oZca/MfsYBW0Fa/yBUGXFZKxJ05DfDNeWj5XaOoU4Mo=";
      };
      meta.homepage = "https://github.com/slugbyte/lackluster.nvim";
    };
  };
}
