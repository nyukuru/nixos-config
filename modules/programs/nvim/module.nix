{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit
    (lib.options)
    mkPackageOption
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.strings)
    hasSuffix
    ;

  inherit
    (lib.files)
    concatMapFiles
    ;

  inherit
    (lib.filesystem)
    listFilesRecursive
    ;

  inherit
    (lib.lists)
    optionals
    filter
    elem
    map
    ;

  inherit
    (lib.types)
    package
    nullOr
    listOf
    lines
    path
    str
    ;

  cfg = config.nyu.programs.nvim;
in {
  imports = [
    ./default-config
  ];

  options.nyu.programs.nvim = {
    enable = mkEnableOption "Neovim text editor";
    package = mkPackageOption pkgs "neovim-unwrapped" {};

    viAlias = mkEnableOption "Neovim symlink over vi" // {default = true;};
    vimAlias = mkEnableOption "Neovim symlink over vim" // {default = true;};

    configDir = mkOption {
      type = nullOr path;
      default = null;
      description = "The directory that hosts the neovim configuration (lua and vim files).";
    };

    extra = {
      vim = mkOption {
        type = lines;
        default = "";
        description = "VimL content to be appended on the generated init.vim.";
      };
      lua = mkOption {
        type = lines;
        default = "";
        description = "Lua content to be appended on the generated init.lua.";
      };
    };

    exclude = mkOption {
      type = listOf str;
      default = [];
      description = "Filenames to exclude from the config if found in the config directory.";
    };

    plugins = {
      start = mkOption {
        type = listOf package;
        default = [];
        description = "Plugins loaded at start.";
      };

      opt = mkOption {
        type = listOf package;
        default = [];
        description = "Plugins loaded upon invocation in neovim.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = let
      allFiles =
        optionals (cfg.configDir != null)
        (filter (x: !(elem (baseNameOf x) cfg.exclude)) (listFilesRecursive cfg.configDir));
      vimFiles = filter (x: hasSuffix ".vim" x) allFiles;
      luaFiles = filter (x: hasSuffix ".lua" x) allFiles;
    in [
      (pkgs.wrapNeovimUnstable cfg.package {
        inherit (cfg) viAlias vimAlias;

        neovimRcContent = (concatMapFiles vimFiles) + cfg.extra.vim;
        luaRcContent = (concatMapFiles luaFiles) + cfg.extra.lua;

        plugins =
          cfg.plugins.start
          ++ (map
            (x: {
              plugin = x;
              optional = true;
            })
            cfg.plugins.opt);
      })
    ];
  };
}
