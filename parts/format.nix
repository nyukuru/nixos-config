{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {
    inputs',
    config,
    pkgs,
    lib,
    ...
  }: {
    formatter = config.treefmt.build.wrapper;

    treefmt = {
      settings = {
        global.excludes = [".git/*"];
      };

      programs = {
        alejandra = {
          enable = true;
        };
      };
    };
  };
}
