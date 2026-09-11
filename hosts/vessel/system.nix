{
  config,
  lib,
  ...
}: {
  boot = {
    kernel.sysctl = {
      "kernel.yama.ptrace_scope" = 1;
      "net.core.bpf_jit_enable" = 1;
    };

    extraModprobeConfig = ''
      options iwlwifi power_save=1 disable_11ax=1
    '';

    loader.limine.extraEntries = ''
      /Windows 11
        protocol: efi
        path: guid(614740dc-b9a7-4774-ac6e-32eae9d9fdbd):/EFI/Microsoft/Boot/bootmgfw.efi
    '';

    # From generated hardware-config
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
  };

  # Permission for media drive
  users.extraGroups.media = {};

  /*
    ____          _                    __  __           _       _
   / ___|   _ ___| |_ ___  _ __ ___   |  \/  | ___   __| |_   _| | ___  ___
  | |  | | | / __| __/ _ \| '_ ` _ \  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
  | |__| |_| \__ \ || (_) | | | | | | | |  | | (_) | (_| | |_| | |  __/\__ \
   \____\__,_|___/\__\___/|_| |_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___||___/
  */
  nyu = {
    hardware = {
      cpu = "intel";
      igpu = "intel";
      dgpu = "nvidia";

      tpm.enable = true;
      bluetooth.enable = true;
    };

    boot = {
      greetd.autologin = {
        enable = true;
        user = "nyu";
        command = let
          session = lib.getExe config.nyu.programs.niri.package;
          sessionWrapper = "${lib.getExe config.programs.uwsm.package} start";
        in "${sessionWrapper} ${session} >/dev/null";
      };
    };
  };
}
