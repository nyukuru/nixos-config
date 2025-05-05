{pkgs, ...}: {
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

    obs-studio = {
      enable = true;
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

    thunar = {
      enable = true;
    };

    zsh.interactiveShellInit = ''
      function osc7-pwd() {
        emulate -L zsh # also sets localoptions for us
        setopt extendedglob
        local LC_ALL=C
        printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
      }

      function chpwd-osc7-pwd() {
          (( ZSH_SUBSHELL )) || osc7-pwd
      }

      precmd() {
          print -Pn "\e]133;A\e\\"
      }

      function precmd {
          if ! builtin zle; then
              print -n "\e]133;D\e\\"
          fi
      }

      function preexec {
          print -n "\e]133;C\e\\"
      }

      autoload -U add-zsh-hook
      add-zsh-hook -Uz chpwd chpwd-osc7-pwd
    '';
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

    fusee-nano = {
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
        "bitwarden-password-manager" = {installMode = "force_installed";};
      };
    };
  };
}
