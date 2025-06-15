{
 nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (prevGamescope: {
        patches = (prevGamescope.patches or []) ++ [
          (prev.fetchpatch {
            url = "https://github.com/mahkoh/gamescope/commit/5266372f377c58d7c5511a962032095af3f56c1e.patch";
            hash = "sha256-12mSG5cEoMlBN1oMoxlVftuh7nXIZqLPpBbVdeyNxiU=";
          })
        ];
      });
    })
  ];
}
