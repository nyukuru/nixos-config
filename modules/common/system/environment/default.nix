{
  imports = [
    # Shell aliases
    ./aliases.nix
    # Declare needed system agnostic packages
    ./packages.nix
    # Environment variables defaults
    ./variables.nix
    # ~Internationalization~
    ./locale.nix
  ];
}
