{
  pkgs,
  packages,
  config,
  inputs,
  modulesPath,
  ...
}: let 
  inherit 
    (config.style)
    colors
    ;

  gaps = config.nyu.programs.sway.settings.gaps.inner;

in {
  disabledModules = [ "${modulesPath}/programs/wayland/waybar.nix" ];
  imports = [ "${inputs.dev-nixpkgs-waybar}/nixos/modules/programs/wayland/waybar.nix" ];

  programs.waybar = {
    enable = true;

    settings = {
      layer = "top";
      position = "top";

      height = 25;

      margin-top = gaps;
      margin-right = gaps;
      margin-left = gaps;
      margin-bottom = 0;

      modules-left = [
        "custom/launcher"
        "clock"
        "tray"
        "custom/obs"
        "sway/mode"
      ];

      modules-center = [
        "sway/workspaces"
      ];

      modules-right = [
        "pulseaudio"
        "backlight"
        "battery"
      ];

      "custom/launcher" = {
        format = "";
        tooltip = false;
        # TODO
      };

      "custom/obs" = {
        exec = packages.waybar-modules.obs-studio;
        interval = 2;
      };

      "sway/workspaces" = {
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
          "4" = [];
          "5" = [];
        };

        format = "";
        window-rewrite-default = "{name}";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon}";
        format-muted = "{volume}% ";
        format-icons = {
          default = ["" "" ""];
        };
        tooltip = false;
      };

      backlight = {
        format = "{percent}% {icon}";
        format-icons = ["󰃞" "󰃝" "󰃟" "󰃠"];
        tooltip = false;
      };

      battery = {
        format = "{capacity}% {icon}";
        format-icons = ["" "" "" "" ""];
      };

      clock = {
        format = "{:%b. %d; %H:%M}";
        tooltip = false;
      };

      tray = {
        spacing = 10;
      };
    };
  };

  environment.etc."xdg/waybar/style.css".source = pkgs.writeText "waybar-style.css" ''
    * {
      min-height: 0;
    }

    window#waybar {
      background-color: #${colors.base0};
      border-radius: 5px;
      color: #${colors.base7};
    }

    .module {
      border: 2px solid #${colors.base7};
      border-radius: 5px;
      padding: 0 10px;
      margin: 5px;
    }

    #custom-launcher {
      border: 0;
      font-size: 15px;
      margin-right: 0;
    }

    #workspaces {
      min-width: 100px;
    }

    #workspaces button {
      all: unset;
      background-color: #${colors.base7};
      margin: 5px;
      font-size: 0px;
      padding: 0 4px;
      transition: padding 0.2s;
    }

    #workspaces button.focused {
      padding: 0 10px;
    }
  '';
}
