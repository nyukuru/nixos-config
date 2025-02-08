{
  perSystem = {
    pkgs,
    ...
  }: {
    imports = [./nvim-plugins.nix];

    packages = {
      # Plymouth bootscreen themes
      plymouth-copland-theme = pkgs.callPackage ./plymouth-themes/plymouth-copland-theme.nix {};
      plymouth-hellonavi-theme = pkgs.callPackage ./plymouth-themes/plymouth-hellonavi-theme.nix {};

    };
  };
}
