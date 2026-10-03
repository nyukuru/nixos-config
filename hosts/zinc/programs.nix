let
  mainOutput = "ASUSTek COMPUTER INC VG248 LALMQS110173";
  sideOutput = "ASUSTek COMPUTER INC VG248 LALMQS110163";
in {
  # Fan curves for the motherboard headers (through it87) and the GPU
  programs.coolercontrol.enable = true;

  programs.niri.settings = {
    outputs.${mainOutput}.focus-at-startup = true;

    workspaces = {
      "1".open-on-output = mainOutput;
      "2".open-on-output = mainOutput;
      "3".open-on-output = mainOutput;
      "4".open-on-output = mainOutput;
      "5".open-on-output = mainOutput;

      "side-1" = {
        name = "6";
        open-on-output = sideOutput;
      };
      "side-2" = {
        name = "7";
        open-on-output = sideOutput;
      };
      "side-3" = {
        name = "8";
        open-on-output = sideOutput;
      };
      "side-4" = {
        name = "9";
        open-on-output = sideOutput;
      };
      "side-5" = {
        name = "10";
        open-on-output = sideOutput;
      };
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
    fusee-nano.enable = true;

    firefox = {
      languagePacks = ["en-US"];

      /*
      clearurls = "{74145f27-f039-47ce-a470-a662b129930a}";
      sponsorblock = "sponsorBlocker@ajay.app";
      simple-translate = "simple-translate@sienori";
      bento = "{cb7f7992-81db-492b-9354-99844440ff9b}";
      */
      extensions = [
        {
          shortID = "skip-redirect";
          addonID = "skipredirect@sblask";
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
