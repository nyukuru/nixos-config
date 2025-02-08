{lib, ...}: let 
  inherit (lib.modules) mkOptionDefaultAttr;

in {  
  environment.variables = mkOptionDefaultAttr {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";

    BROWSER = "firefox";
  };
}
