{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {config, ...}: {
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
