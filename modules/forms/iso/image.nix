{
  config,
  self,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkImageMediaOverride
    ;

  inherit
    (lib.sources)
    cleanSource
    ;

  name = "${config.networking.hostname}-${config.system.nixos.release}-${self.shortRev}";
in {
  # Immutability
  system.switch.enable = false;

  isoImage = {
    squashfsCompression = "zstd -Xcompression-level 19";
    makeEfiBootable = true;

    appendToMenuLabel = "";

    contents = [
      {
        source = pkgs.memtest86plus + "/memtest.bin";
        target = "boot/memtest.bin";
      }
      {
        # Provide flake (minus version control stuff)
        source = cleanSource self;
        target = "/nixos-config";
      }
    ];
  };

  image.baseName = mkImageMediaOverride "${name}.iso";
}
