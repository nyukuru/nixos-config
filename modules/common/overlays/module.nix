{
  nixpkgs.overlays = [
    (finalpkgs: prevpkgs: {
      gamescope = prevpkgs.gamescope.overrideAttrs (prevGamescope: {
        patches =
          (prevGamescope.patches or [])
          ++ [
            (prevpkgs.fetchpatch {
              url = "https://github.com/mahkoh/gamescope/commit/5266372f377c58d7c5511a962032095af3f56c1e.patch";
              hash = "sha256-12mSG5cEoMlBN1oMoxlVftuh7nXIZqLPpBbVdeyNxiU=";
            })
          ];
      });

      python3 = prevpkgs.python3.override {
        packageOverrides = finalpy: prevpy: {
          tpm2-pytss = prevpy.tpm2-pytss.overrideAttrs (prev: {
            patches =
              (prev.patches or [])
              ++ [
                (prevpkgs.fetchpatch {
                  url = "https://github.com/tpm2-software/tpm2-pytss/commit/6ab4c74e6fb3da7cd38e97c1f8e92532312f8439.patch";
                  hash = "sha256-01Qe4qpD2IINc5Z120iVdPitiLBwdr8KNBjLFnGgE7E=";
                })
              ];
          });
        };
      };

      lixPackageSets.latest.lix = prevpkgs.lixPackageSets.latest.lix.overrideAttrs (prev: {
        patches = (prev.patches or []) ++ [./patches/lix/0001-flake-check-allow-nested-packages.patch];
      });
    })
  ];
}
