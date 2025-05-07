{
  pkgs ? import <nixpkgs> {},
  stdenvNoCC ? pkgs.stdenvNoCC,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  lib ? pkgs.lib,
}:
stdenvNoCC.mkDerivation {
  pname = "plymouth-hellonavi-theme";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "nyukuru";
    repo = "hellonavi";
    rev = "247f372a3c91d475a01ac20d7d79f567c21402a3";
    hash = "sha256-YmgVko3SwALf6X8KZiUjdQAStllYVU/bVaH6gpbuBk4=";
  };

  postPatch = ''
    rm readme.md
    rm changelog.md
    rm test_kubuntu16-10.sh
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plymouth/themes
    mv hellonavi $out/share/plymouth/themes
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
    runHook postInstall
  '';

  meta = {
    description = "Plymouth boot theme inspired by Serial Experiments Lain";
    homepage = "https://github.com/yi78/hellonavi";
    platforms = lib.platforms.linux;
  };
}
