{lib, ...}: let
  inherit (lib.modules) mkDefault;

in {
  documentation = {
    enable = mkDefault true;

    # Whether to install documentation distributed in packages’ /share/doc. 
    # Usually plain text and/or HTML. This also includes “doc” outputs.
    doc.enable = mkDefault false;

    # Whether to install info pages and the info command. This also includes “info” outputs.
    info.enable = mkDefault false;

    # NixOS documentation
    # - man pages like configuration.nix(5) if documentation.man.enable is set.
    # - HTML manual and the nixos-help command if documentation.doc.enable is set.
    # Causes some unneeded rebuilding.
    nixos.enable = mkDefault false;

    # Whether to install manual pages. This also includes man outputs.
    man.enable = mkDefault true;
  };
}
