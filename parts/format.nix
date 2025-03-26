{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {config, ...}: {
    formatter = config.treefmt.build.wrapper;

    treefmt = {
      settings = {
        global.excludes = [".git/*"];
      };

      programs = {
        alejandra = {
          enable = true;
        };

        stylua = {
          enable = true;
        };
      };
    };
  };
}
