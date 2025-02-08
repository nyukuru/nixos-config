{
  pkgs ?
    import <nixpkgs>
    {}
    .stdenvNoCC
    ? pkgs.stdenvNoCC,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  lib ? pkgs.lib,
}:
stdenvNoCC.mkDerivation {
  pname = "plymouth-copland-theme";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mdfaisalhsn";
    repo = "copland-plymouth-theme";
    rev = "4e6bd8d881683044448e59ea3884e2e74940d334";
    hash = "sha256-/w0AigJWBVdi+JQWb08sT5BgZyeprycLkMz7fuRPCHE=";
  };

  postPatch = ''
    rm README.md
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plymouth/themes
    mv copland $out/share/plymouth/themes
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
    runHook postInstall
  '';

  meta = {
    description = "Plymouth boot theme inspired by Serial Experiments Lain";
    homepage = "https://github.com/mdfaisalhsn/copland-plymouth-theme";
    platforms = lib.platforms.linux;
  };
}
