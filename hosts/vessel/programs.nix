{pkgs, ...}: {
  programs = {
    foot.enable = true;
    nix-ld.enable = true;
    thunar.enable = true;

    nh = {
      enable = true;
      flake = "/home/nyu/nixos-config";
      clean = {
        enable = true;
        extraArgs = "--keep-since 3d --keep 5";
        dates = "Sun";
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
      ];
    };
  };
  /*
    ____          _                    __  __           _       _
   / ___|   _ ___| |_ ___  _ __ ___   |  \/  | ___   __| |_   _| | ___  ___
  | |  | | | / __| __/ _ \| '_ ` _ \  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
  | |__| |_| \__ \ || (_) | | | | | | | |  | | (_) | (_| | |_| | |  __/\__ \
   \____\__,_|___/\__\___/|_| |_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___||___/
  */
  nyu.programs = {
    niri.enable = true;
    nvim.enable = true;
    fusee-nano.enable = true;

    zsh = {
      enable = true;
      starship.enable = true;
    };

    firefox = {
      enable = true;
      languagePacks = ["en-US"];

      /*
      clearurls = "{74145f27-f039-47ce-a470-a662b129930a}";
      sponsorblock = "sponsorBlocker@ajay.app";
      simple-translate = "simple-translate@sienori";
      bento = "{cb7f7992-81db-492b-9354-99844440ff9b}";
      */
      extensions = [
        {
          shortID = "ublock-origin";
          addonID = "uBlock0@raymondhill.net";
        }
        #{
        #  shortID = "hide-youtube-shorts";
        #  addonID = "";
        #}
        {
          shortID = "skip-redirect";
          addonID = "skipredirect@sblask";
        }
        {
          shortID = "languagetool";
          addonID = "languagetool-webextension@languagetool.org";
        }
        {
          shortID = "frankerfacez";
          addonID = "frankerfacez@frankerfacez.com";
        }
        {
          shortID = "disable-twitch-extensions";
          addonID = "disable-twitch-extensions@rootonline.de";
        }
        {
          shortID = "bitwarden-password-manager";
          addonID = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
        }
      ];
    };
  };
}
