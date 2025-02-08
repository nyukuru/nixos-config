{pkgs, ...}: {
  packages = let
    inherit (pkgs) fetchFromGitHub;
    inherit (pkgs.vimUtils) buildVimPlugin;
  in {
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
  };
}
