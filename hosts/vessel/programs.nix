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
    # Because sway v1.12 has not reached stable (but it has window capture) I am fetching upstream
    sway = {
      enable = true;
      package = pkgs.sway.override {
        sway-unwrapped =
          (pkgs.sway-unwrapped.overrideAttrs (old: {
            src = pkgs.fetchFromGitHub {
              owner = "swaywm";
              repo = "sway";
              rev = "40aabb80c645519107dc325abc53e4176e896fb9";
              hash = "sha256-jmo11GHz7yR56Q6R/AFkitc4TWvmHj+9IDnpXfzQ7rQ=";
            };
          })).override {
            wlroots_0_19 =
              (pkgs.wlroots.overrideAttrs (old: {
                src = pkgs.fetchFromGitLab {
                  domain = "gitlab.freedesktop.org";
                  owner = "wlroots";
                  repo = "wlroots";
                  rev = "5a40da7e15b145cd10104cb35982649e4050281c";
                  hash = "sha256-+iMl5OpvPQ1cw7BLJLwh6WaKlN1QGKj267cyZ6Vixpk=";
                };
              })).override {
                wayland-protocols = pkgs.wayland-protocols.overrideAttrs (old: {
                  src = pkgs.fetchurl {
                    url = "https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.47/downloads/wayland-protocols-1.47.tar.xz";
                    hash = "sha256-X9Q0m8vJurmkb4z3fR9DQpanoFLIdECglPY/z2KljiA=";
                  };
                });
              };
          };
      };
    };
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
