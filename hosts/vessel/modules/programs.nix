{
  modules.programs = {
    nvim = {
      enable = true;
    };

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
