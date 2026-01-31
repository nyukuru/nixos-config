{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    "${inputs.nix-flatpak}/modules/nixos.nix"
  ];
  services = {
    printing.enable = true;
    joycond.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    btrfs.autoScrub.enable = true;
    gnome.gnome-keyring.enable = true;
    blueman.enable = true;

    udev = {
      enable = true;
      packages = with pkgs; [
        edl
      ];
    };

    dbus = {
      enable = true;
      packages = with pkgs; [
        dconf
        gcr
      ];
    };

    flatpak = {
      enable = true;
      packages = ["org.vinegarhq.Sober"];
    };

    sunshine = {
      enable = true;
      openFirewall = true;
    };
  };

  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1;
  boot.kernel.sysctl."net.core.bpf_jit_enable" = 1;

  systemd.services = {
    fstrim = {
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
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
  nyu.services = {
  };
}
