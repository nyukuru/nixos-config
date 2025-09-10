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

      lixPackageSets.latest.lix = prevpkgs.lixPackageSets.latest.lix.overrideAttrs (prev: {
        patches = (prev.patches or []) ++ [./patches/lix/0001-flake-check-allow-nested-packages.patch];
      });

      ecm = prevpkgs.ecm.overrideAttrs (prevEcm: {
        configureFlags = ["CFLAGS=-std=gnu99"];
      });
    })
  ];
}
