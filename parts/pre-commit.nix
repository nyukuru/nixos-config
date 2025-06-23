{inputs, ...}: {
  imports = [inputs.git-hooks-nix.flakeModule];

  perSystem = {config, ...}: {
    pre-commit = {
      settings = {
        excludes = ["flake.lock"];

        hooks = {
          # Lua
          stylua.enable = true;

          # Nix
          alejandra.enable = true;
          flake-checker.enable = true;
        };
      };
    };

    devShells.default = config.pre-commit.devShell;
  };
}
