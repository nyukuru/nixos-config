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

  environment.systemPackages = with pkgs; [
    powertop
    acpi
  ];

  boot = {
    kernelModules = ["acpi_call"];
    kernelParams = ["intel_pstate=disabled"]; # reccomended for auto-cpufreq
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
      cpupower
    ];
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    scsiLinkPolicy = "med_power_with_dipm";
  };
}
