{
  lib,
  pkgs,
  config,
  inputs,
  modulesPath,
  ...
}: let
  inherit (lib.attrsets) mergeAttrsList;
  inherit (lib.lists) imap0;

  inherit (config.style) colors;

  gaps = config.nyu.programs.sway.settings.gaps.inner;
in {
  disabledModules = ["${modulesPath}/programs/wayland/waybar.nix"];
  imports = ["${inputs.dev-nixpkgs-waybar}/nixos/modules/programs/wayland/waybar.nix"];

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
        #"custom/obs"
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

      /*
      "custom/obs" = {
        exec = pkgs.waybar-modules.obs-studio;
        interval = 2;
      };
      */

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

      battery = let
        dischargingIcons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        chargingIcons = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];

        iconsToFormat = status: icons:
          mergeAttrsList (
            imap0 (i: v: {
              "format-${status}-${toString i}" = "{capacity}% ${v}";
            })
            icons
          );
      in
        {
          interval = 5;
          states = {
            "0" = 5;
            "1" = 15;
            "2" = 25;
            "3" = 35;
            "4" = 45;
            "5" = 55;
            "6" = 65;
            "7" = 75;
            "8" = 85;
            "9" = 95;
            "10" = 100;
          };
          format-full = "{capacity}% 󰁹";
        }
        // (iconsToFormat "discharging" dischargingIcons)
        // (iconsToFormat "charging" chargingIcons);

      clock = {
        format = "{:%b. %d; %H:%M}";
        tooltip = false;
      };

      tray = {
        spacing = 10;
      };
    };
  };

  environment.etc."xdg/waybar/style.css".text = ''
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
