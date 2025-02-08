{
  imports = [
    # Defaults for boot sequence and kernel level config.
    ./boot

    # Defaults for sound servers (conditionally enabled by the sound module).
    ./sound

    # Defaults for nix language and the nix language environment (nixpkgs).
    ./nix

    # Defaults for display environment (wms).
    ./display

    # Default qualities of default users.
    ./users

    # Default network configuration, prioritize security.
    ./networking

    # Environment defaults.
    ./environment

    # Default fonts.
    ./fonts.nix

    # Hardened nix.
    ./security.nix
  ];
}
