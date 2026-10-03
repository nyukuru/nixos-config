{
  config,
  lib,
  ...
}: {
  boot = {
    loader.limine.extraEntries = ''
      /Windows 11
        protocol: efi
        path: guid(614740dc-b9a7-4774-ac6e-32eae9d9fdbd):/EFI/Microsoft/Boot/bootmgfw.efi
    '';

    # The X570 AORUS ELITE's fan headers sit on an IT8688E, which the in-tree
    # it87 driver doesn't support; install the out-of-tree one under updates/
    # so depmod prefers it over the in-tree module of the same name.
    extraModulePackages = [
      (config.boot.kernelPackages.it87.overrideAttrs (old: {
        postInstall =
          (old.postInstall or "")
          + ''
            dir=$(echo $out/lib/modules/*)
            mkdir -p $dir/updates
            mv $dir/kernel/drivers/hwmon/it87.ko $dir/updates/
          '';
      }))
    ];
    kernelModules = ["it87"];
    # Gigabyte boards claim the Super I/O ports in ACPI
    extraModprobeConfig = ''
      options it87 ignore_resource_conflict=1
    '';

    # From generated hardware-config
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "nvme"
      "sd_mod"
    ];
  };

  /*
    ____          _                    __  __           _       _
   / ___|   _ ___| |_ ___  _ __ ___   |  \/  | ___   __| |_   _| | ___  ___
  | |  | | | / __| __/ _ \| '_ ` _ \  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
  | |__| |_| \__ \ || (_) | | | | | | | |  | | (_) | (_| | |_| | |  __/\__ \
   \____\__,_|___/\__\___/|_| |_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___||___/
  */
  nyu = {
    hardware = {
      cpu = "amd";
      igpu = null;
      dgpu = "nvidia";

      tpm.enable = true;
      bluetooth.enable = true;
    };

    boot = {
      greetd.autologin = {
        enable = true;
        user = "nyu";
        command = let
          session = lib.getExe config.programs.niri.package;
          sessionWrapper = "${lib.getExe config.programs.uwsm.package} start";
        in "${sessionWrapper} ${session} >/dev/null";
      };
    };
  };
}
