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
    Base2Tone-nvim = buildVimPlugin {
      pname = "Base2Tone.nvim";
      version = "2022-12-07";
      src = fetchFromGitHub {
        owner = "atelierbram";
        repo = "Base2Tone-nvim";
        rev = "c32c1d3dfdc8fb6e91cbf6078c078d6c3eaaa673";
        sha256 = "sha256-XcPZBL4QeiQVCtIoZF63vHdQjl7aCf408MhiFvlrwvI=";
      };
      meta.homepage = "https://github.com/atelierbram/Base2Tone-nvim";
    };

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
