{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./auto-cpufreq.nix
    ./acpid.nix
    ./upower.nix
  ];
  
  environment.systemPackages = [
    pkgs.acpi
    pkgs.powertop
  ];

  boot = {
    kernelModules = [ "acpi_call" ];
    kernelParams = [ "intel_pstate=disabled" ]; # reccomended for auto-cpufreq
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
      cpupower
    ];
  };
}
