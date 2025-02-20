{inputs', ...}: {
  imports = [
    ./nvim
  ];

  modules.programs = {
    zsh = {
      enable = true;
      starship.enable = true;
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
