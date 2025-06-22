{
  stdenvNoCC,
  fetchFromGitHub,
  imagemagick,
  lib,
  color ? "FFFFFF",
}:
stdenvNoCC.mkDerivation {
  pname = "plymouth-hellonavi-theme";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "nyukuru";
    repo = "hellonavi";
    rev = "c7c08625cc2e35f92cd6347892b1b34133a8e975";
    hash = "sha256-OaUH/PdxgpPLznuGsJadB4WVZ3l/rdi+QXM4aRvX4i0=";
  };

  postPatch = ''
    rm readme.md
    rm changelog.md
    rm test_kubuntu16-10.sh

    for img in hellonavi/img/navi*.png; do
      magick \( -size 150x150 xc:"#${color}" \) "$img" -compose multiply -composite "$img"
    done
  '';

  dontBuild = true;

  nativeBuildInputs = [
    imagemagick
  ];

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
