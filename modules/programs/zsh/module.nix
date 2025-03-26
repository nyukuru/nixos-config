{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.attrsets)
    attrAny
    ;

  inherit
    (lib.lists)
    optional
    ;

  inherit
    (lib.types)
    str
    ;

  isDefaultShell =
    (config.users.defaultUserShell
      == pkgs.zsh)
    || (attrAny (x: x.shell == pkgs.zsh) config.users.users);

  cfg = config.nyu.programs.zsh;
in {
  options.nyu.programs.zsh = {
    enable = mkEnableOption "ZSH shell.";

    starship = {
      enable = mkEnableOption "Starship prompt.";
      prompt = mkOption {
        type = str;
        default = "";
        description = "Starship prompt string.";
      };
    };
  };

  config = mkIf (cfg.enable || isDefaultShell) {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      promptInit =
        if cfg.starship.enable
        then ''eval "$(${pkgs.starship}/bin/starship init zsh)"''
        else ''autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp'';
    };

    environment.systemPackages = optional cfg.starship.enable pkgs.starship;
  };
}
