{
  users.users.nyu = {
    isNormalUser = true;
    uid = 1001;

    createHome = true;
    home = "/home/nyu";

    initialHashedPassword = "$y$j9T$QwZHlCs7AJpoQK2WE.erA1$LnsEPvK.12mlbkNxk9K3DrL8IHnLIY2fwNSznLqISPA";
    extraGroups = [
      "wheel"
      "systemd-journal"
      "audio"
      "video"
      "input"
      "power"
      "network"
      "nix"
      "networkmanager"

      "media"
      "nintendo-switch"
    ];
  };
}
