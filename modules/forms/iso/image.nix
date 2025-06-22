{
  config,
  inputs,
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

  inherit (inputs) self;
in {
  system.switch.enable = false;

  isoImage = {
    squashfsCompression = "zstd -Xcompression-level 19";
    appendToMenuLabel = "";

    makeBiosBootable = true;
    makeEfiBootable = true;
    makeUsbBootable = true;

    contents = [
      {
        source = cleanSource self;
        target = "/nixos-config";
      }
    ];
  };

  image.baseName = mkImageMediaOverride "${config.networking.hostName}-${self.shortRev or self.dirtyShortRev}";
}
