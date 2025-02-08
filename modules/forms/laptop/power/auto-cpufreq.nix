{
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault;

in {
  services = {
    auto-cpufreq = {
      enable = true;
      settings = let
        MHz = x: x * 1000;
      in {
        charger = {
          governor = "powersave";
          energy_performance_preference = "power";
          scaling_min_freq = mkDefault (MHz 1200);
          scaling_max_freq = mkDefault (MHz 3000);
          turbo = "auto";
        };
        battery = {
          governor = "powersave";
          energy_performance_preference = "power";
          scaling_min_freq = mkDefault (MHz 1200);
          scaling_max_freq = mkDefault (MHz 1800);
          turbo = "never";
        };
      };
    };

    tlp.enable = false;
  };
}
