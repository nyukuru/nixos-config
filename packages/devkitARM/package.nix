{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "devkitARM";
  version = "65";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = "buildScripts";
    tag = "devkitARM_r${finalAttrs.version}";
    hash = "sha256-HBZX+lEw76GXA05GdjCWMaE/kqO8YJV55rOkVbNyxeQ=";
  };

  BUILD_DKPRO_AUTOMATED = 1;
  BUILD_DKPRO_PACKAGE = 1;

  buildPhase = ''
    ./build-devkit.sh
  '';
})
