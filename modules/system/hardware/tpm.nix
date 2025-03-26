{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  cfg = config.nyu.hardware.tpm;
in {
  options.nyu.hardware.tpm = {
    enable = mkEnableOption "TPM.";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = ["uhid"];

    security.tpm2 = {
      enable = true;

      # Makes /dev/tpm[0-9] accessible to tss user.
      applyUdevRules = true;

      # Exports interface environment variables.
      tctiEnvironment.enable = true;

      # Resource manager daemon.
      abrmd.enable = true;

      # Cryptographic library and tooling.
      pkcs11.enable = true;
    };

    environment.systemPackages = with pkgs; [
      tpm2-tools
      tpm2-tss
    ];
  };
}
