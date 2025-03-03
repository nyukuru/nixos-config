{
  pkgs,
  ...
}: {
  programs = {
    nix-ld = {
      enable = true;
    };

    nh = {
      enable = true;
      clean = {
	enable = true;
	extraArgs = "--keep-since 3d --keep 5";
	dates = "Sun";
      };
    };



    # cuda needed for nvenc 
    obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {cudaSupport = true;};

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
	obs-pipewire-audio-capture
      ];
    };

    steam = {
      enable = true;
    };

    gamemode = {
      enable = true;
    };

    foot = {
      enable = true;
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
    sway = {
      enable = true;
    };


    zsh = {
      enable = true;
      starship.enable = true;
    };

    nvim = {
      # Config is default-config in module definition
      enable = true;
    };

    dunst = {
      enable = true;
    };

    firefox = {
      enable = true;

      languagePacks = ["en-US"];
      extensions = {
        "ublock-origin" = {installMode = "force_installed";};
        "skip-redirect" = {installMode = "force_installed";};
        "frankerfacez" = {installMode = "force_installed";};
        "disable-twitch-extensions" = {installMode = "force_installed";};
      };
    };
  };
}
