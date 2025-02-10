{
  imports = [
    ./boot.nix

    # Defaults for sound servers (conditionally enabled by the sound module).
    ./sound

    # Defaults for nix language and the nix language environment (nixpkgs).
    ./nix

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
