{
  lib,
  config,
  ...
}: let
  inherit 
    (lib.options)
    literalExpression
    mkOption
    ;

  inherit
    (lib.lists)
    concatMap
    ;

  inherit
    (lib.attrsets)
    optionalAttrs
    ;

  inherit
    (lib.strings)
    concatMapAttrsStringSep
    ;

  inherit
    (lib.generators)
    toINI
    ;

  inherit
    (lib.types)
    submodule
    package
    attrsOf
    nullOr
    oneOf
    lines
    bool
    int
    str
    ;

  themeType = submodule {
    options = {
      package = mkOption {
        type = nullOr package;
        default = null;
        example = literalExpression "pkgs.gnome.gnome-themes-extra";
        description = ''
          Package providing the theme. This package will be installed
          to your profile. If `null` then the theme
          is assumed to already be available in your profile.

          For the theme to apply to GTK 4, this option is mandatory.
        '';
      };

      name = mkOption {
        type = str;
        example = "Adwaita";
        description = "The name of the theme within the package.";
      };
    };
  };

  iconThemeType = submodule {
    options = {
      package = mkOption {
        type = nullOr package;
        default = null;
        example = literalExpression "pkgs.adwaita-icon-theme";
        description = ''
          Package providing the icon theme. This package will be installed
          to your profile. If `null` then the theme
          is assumed to already be available in your profile.
        '';
      };

      name = mkOption {
        type = str;
        example = "Adwaita";
        description = "The name of the icon theme within the package.";
      };
    };
  };

  fontType = submodule {
    options = {
      package = mkOption {
        type = nullOr package;
        default = null;
        example = literalExpression "pkgs.jetbrains-mono";
        description = ''
          Package providing the font. This package will be installed.
          If 'null' then the theme is assumed to already be available.
        '';
      };

      name = mkOption {
        type = str;
        example = "Jetbrains Mono";
        description = "The name of the icon theme within the package.";
      };

      size = mkOption {
        type = int;
        default = 10;
        description = ''
          Size to prefer the font to be in.
        '';
      };
    };
  };

  cfg = config.style.gtk;

in {
  options.style.gtk = {
    font = mkOption {
      type = nullOr fontType;
      default = config.style.font;
      description = ''
        The font to use in GTK+ applications.
      '';

    };

    iconTheme = mkOption {
      type = nullOr iconThemeType;
      default = null;
      description = "The icon theme to use.";
    };

    theme = mkOption {
      type = nullOr themeType;
      default = null;
      description = "The GTK+ theme to use.";
    };

    gtk2 = {
      extraConfig = mkOption {
        type = lines;
        default = "";
        example = "gtk-can-change-accels = 1";
        description = ''
          Extra configuration lines to add verbatim to
          {file}`/etc/xdg/gtk-2.0/gtkrc`.
        '';
      };
    };

    gtk3 = {
      extraConfig = mkOption {
        type = attrsOf (oneOf [bool int str]);
        default = { };
        example = {
          gtk-cursor-blink = false;
          gtk-recent-files-limit = 20;
        };
        description = ''
          Extra configuration options to add to
          {file}`/etc/xdg/gtk-3.0/settings.ini`.
        '';
      };

      extraCss = mkOption {
        type = lines;
        default = "";
        description = ''
          Extra configuration lines to add verbatim to
          {file}`/etc/xdg/gtk-3.0/gtk.css`.
        '';
      };
    };

    gtk4 = {
      extraConfig = mkOption {
        type = attrsOf (oneOf [bool int str]);
        default = { };
        example = {
          gtk-cursor-blink = false;
          gtk-recent-files-limit = 20;
        };
        description = ''
          Extra configuration options to add to
          {file}`/etc/xdg/gtk-4.0/settings.ini`.
        '';
      };

      extraCss = mkOption {
        type = lines;
        default = "";
        description = ''
          Extra configuration lines to add verbatim to
          {file}`/etc/xdg/gtk-4.0/gtk.css`.
        '';
      };
    };
  };
  config = let
    gtkIni = optionalAttrs (cfg.font != null) {
      gtk-font-name = "${cfg.font.name} ${toString cfg.font.size}";
    }
    // optionalAttrs (cfg.theme != null) {
      gtk-theme-name = cfg.theme.name;
    }
    // optionalAttrs (cfg.iconTheme != null) {
      gtk-icon-theme-name = cfg.iconTheme.name;
    };

    dconfIni = optionalAttrs (cfg.font != null) {
      font-name ="${cfg.font.name} ${toString cfg.font.size}";
    }
    // optionalAttrs (cfg.theme != null) { 
      gtk-theme = cfg.theme.name; 
    }
    // optionalAttrs (cfg.iconTheme != null) {
      icon-theme = cfg.iconTheme.name;
    };

    toGtk3Ini = toINI {
      mkKeyValue = key: value: "${lib.escape ["="] key}=${builtins.toJSON value}";
    };

    toGtk2Rc = concatMapAttrsStringSep "\n" (n: v: "${lib.escape ["="] n} = ${builtins.toJSON v}}");

    gtk4Css = if (cfg.theme.package or null == null) then "" else ''
      @import url("file://${cfg.theme.package}/share/themes/${cfg.theme.name}/gtk-4.0/gtk.css")
    '';

    optionalPackages = concatMap (x: if x.package or null == null then [] else [x.package]);
  in {
    fonts.packages = optionalPackages [cfg.font];

    environment = {
      systemPackages = optionalPackages [
        cfg.theme
        cfg.iconTheme
      ];

      etc = {
        "xdg/gtk-2.0/gtkrc".text = "${toGtk2Rc gtkIni}\n${cfg.gtk2.extraConfig}\n";

        "xdg/gtk-3.0/settings.ini".text = toGtk3Ini {Settings = gtkIni // cfg.gtk3.extraConfig;};
        "xdg/gtk-3.0/gtk.css".text = cfg.gtk3.extraCss;

        "xdg/gtk-4.0/settings.ini".text = toGtk3Ini {Settings = gtkIni // cfg.gtk4.extraConfig;};
        "xdg/gtk-4.0/gtk.css".text = gtk4Css + cfg.gtk4.extraCss;
      };
    };

    programs.dconf.profiles.user.databases = [{
      lockAll = true;
      settings."org/gnome/desktop/interface" = dconfIni;
    }];
  };
}
