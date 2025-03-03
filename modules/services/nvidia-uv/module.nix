{
  config,
  pkgs,
  lib,
  ...
}: let
  
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.types)
    nullOr
    int
    ;

  inherit
    (lib.asserts)
    assertMsg
    ;

  cfg = config.nyu.services.nvidia-uv;

in {
  options.nyu.services.nvidia-uv = {
    enable = mkEnableOption "Nvidia Undervolting/Overclocking Service.";

    minCoreClock = mkOption {
      type = nullOr int;
      default = null;
      description = ''
        The minimum supported core clock of your GPU

	`nvidia-smi -q -d SUPPORTED_CLOCKS | less`
      '';
    };

    maxCoreClock = mkOption {
      type = nullOr int;
      default = null;
      description = ''
        The maximum supported core clock of your GPU

	`nvidia-smi -q -d SUPPORTED_CLOCKS | less`
      '';
    };

    clockOffset = mkOption {
      type = int;
      default = 0;
      description = ''
        Clock offset of the gpu.
      '';
    };

    memOffset = mkOption {
      type = int;
      default = 0;
      description = ''
        Memory offset of the gpu.
      '';
    };

    gpuIndex = mkOption {
      type = int;
      default = 0;
      description = ''
        Index of the gpu to undervolt/overclock

	Should be 0 unless using a multi-gpu system
      '';
    };
  };

  config = mkIf cfg.enable (let
    
    minCoreClock = assertMsg (cfg.minCoreClock != null) ''
      minCoreClock is undefined, which is required to enable the nvidia undervolt/overclock.
    '';

    maxCoreClock = assertMsg (cfg.minCoreClock != null) ''
      maxCoreClock is undefined, which is required to enable the nvidia undervolt/overclock.
    '';
    

  in {

    systemd.services.nvidia-uv = {
      description = "Undervolt/Overclocking service for Nvidia GPUs";

      wantedBy = ["graphical.target"];

      serviceConfig = {
        Type = "oneshot";
	Restert = "no";
	ExecStart = pkgs.writers.writePython3 "nvidia-uv.py" {libraries = [pkgs.python312Packages.nvidia-ml-py];} ''
	  from pynvml import *
	  nvmlInit()

	  myGPU = nvmlDeviceGetHandleByIndex(${cfg.gpuIndex})

	  # Set Min and Max core clocks
	  nvmlDeviceSetGpuLockedClocks(myGPU, ${minCoreClock}, ${maxCoreClock})

	  # Clock offset
	  nvmlDeviceSetGpcClkVfOffset(myGPU, ${cfg.clockOffset})

	  # Memory Clock offset
	  nvmlDeviceSetMemClkVfOffset(myGPU, ${cfg.memOffset}) 
	'';
      };
    };
  });
}
