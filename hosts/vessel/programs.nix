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

    # Launch with nvidia-offload for nvenc 
    obs-studio = {
      enable = true;
      package = pkgs.symlinkJoin {
        name = "nv-obs";
	nativeBuildInputs = [ pkgs.makeWrapper];

	paths = [
	  (pkgs.obs-studio.override {cudaSupport = true;})
	];

	postBuild = ''
	  wrapProgram $out/bin/obs \
            --set __NV_PRIME_RENDER_OFFLOAD "1" \
            --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER "NVIDIA-G0" \
            --set __GLX_VENDOR_LIBRARY_NAME "nvidia" \
            --set __VK_LAYER_NV_optimus "NVIDIA_only" \
	'';
      };

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
  modules.programs = {
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
