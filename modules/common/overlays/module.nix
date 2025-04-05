{
 nixpkgs.overlays = [
    (final: prev: {

      # Relax dependencies to allow build
      /*
      auto-cpufreq = prev.auto-cpufreq.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          (prev.fetchpatch {
            name = "auto-cpufreq-2.5.0-ps-util-relax-constraints.patch";
            url = "https://github.com/AdnanHodzic/auto-cpufreq/commit/8f026ac6497050c0e07c55b751c4b80401e932ec.patch";
            sha256 = "sha256-hcEcuy7oW4fZgfOLSap3pnWk7H1Q757tgfl7HIUyWiM=";
          })
        ];
      });
      */
    })
  ];
}
