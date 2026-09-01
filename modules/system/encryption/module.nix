{
  pkgs,
  config,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.options)
    mkEnableOption
    ;

  inherit
    (lib.meta)
    getExe
    ;

  cfg = config.nyu.encryption;
in {
  options.nyu.encryption = {
    enable = mkEnableOption "LUKS encryption.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.tpm2-tools];

    boot = {
      kernelParams = [
        "luks.options=timeout=0"
        "rd.luks.options=timeout=0"
        "rootflags=x-systemd.device-timeout=0"
      ];

      initrd = {
        availableKernelModules = [
          "aesni_intel"
          "cryptd"
          "usb_storage"
        ];

        systemd.extraBin.cryptsetup = getExe pkgs.cryptsetup;
      };
    };
  };
}
