{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) mapAttrs concatMapAttrs;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str nullOr attrsOf submodule path int listOf package;
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;
  inherit (builtins) baseNameOf;

  cfg = config.modules.system.encryption;
in {
  options.modules.system.encryption = {
    enable = mkEnableOption "LUKS encryption.";

    devices = mkOption {
      default = {};
      type = attrsOf (submodule (
        {name, ...}: {
          options = {
            keyFile = {
              enable = mkEnableOption "Key decode using key stored in secure file.";
              rdKey = mkEnableOption "Auto store the keyfile in initrd.";
              file = mkOption {
                type = nullOr path;
                default = null;
                description = ''
                  The name of the file that should
                  be used as the decryption key for the encrpyed device.
                '';
              };
            };

            # TODO implement all
            yubikey = {
              enable = mkEnableOption "Key decode using yubikey fido device.";
              slot = mkOption {
                type = int;
                default = 2;
                description = ''
                  Yubikey challenge slot.
                '';
              };
            };

            fingerPrint = {
              enable = mkEnableOption "Key decode using encrypted fingerprint data.";
              packages = mkOption {
                type = listOf package;
                default = [pkgs.fprintd];
                description = ''
                  Extra packages or drivers needed to interact with the reader.
                '';
              };
            };

            # ideally tpm2-with-pin
            tpm.enable = mkEnableOption "Key decode with hardware tpm.";
          };
        }
      ));
    };
  };

  config = mkIf cfg.enable {
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

        luks.devices =
          mapAttrs (_: attr: {
            keyFile =
              if attr.keyFile.enable
              then
                if attr.keyFile.rdKey
                then "/secrets/" + baseNameOf attr.keyFile.file
                else attr.keyFile.file
              else null;

            # Improve SSD performance
            bypassWorkqueues = true;
            preLVM = true;
          })
          cfg.devices;

        secrets = let
          mapKeys = concatMapAttrs (
            _: attr:
              mkIf (attr.keyFile.enable && attr.keyFile.file != null && attr.keyFile.rdKey) {
                ${"/secrets/" + baseNameOf attr.keyFile.file} = attr.keyFile.file;
              }
          );
        in
          mapKeys cfg.devices;
      };
    };

    warnings = optional (cfg.devices == {}) ''
      LUKS encryption is enabled without any devices set, decryption may not work.
    '';
  };
}
