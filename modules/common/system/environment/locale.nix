{lib, ...}: let
  inherit (lib.modules) mkDefault;

in {
  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  time = {
    timeZone = mkDefault "America/New_York";
    hardwareClockInLocalTime = true;
  };
}
