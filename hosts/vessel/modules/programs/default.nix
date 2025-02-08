{
  imports = [
    ./nvim
  ];

  modules.programs = {
    zsh = {
      enable = true;
      starship.enable = true;
    };

    firefox = {
      enable = true;

      languagePacks = ["en-US"];
      extensions = {
        "ublock-origin" = {};
        "skip-redirect" = {};
        "frankerfacez" = {};
        "disable-twitch-extensions" = {};
      };
    };
  };
}
