{
  pkgs,
  ...
}: {
  services = {
    printing = {
      enable = true;
    };

    dbus = {
      enable = true;
      packages = [
        pkgs.dconf
	pkgs.gcr
      ];
    };

    gnome.gnome-keyring = {
      enable = true;
    };
  };
}
