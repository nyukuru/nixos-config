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
      applyUdevRules = true;
      tctiEnvironment.enable = true;
      abrmd.enable = true;
      pkcs11.enable = true;
    };

    environment.systemPackages = with pkgs; [
      tpm2-tools
      tpm2-tss
    ];
  };
}
