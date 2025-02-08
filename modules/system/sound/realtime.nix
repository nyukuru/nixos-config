# Lower latency audio, ripped partly from:
# https://github.com/musnix/musnix
# https://gitlab.archlinux.org/archlinux/packaging/packages/realtime-privileges
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.strings) optionalString makeSearchPath;
  inherit (lib.types) nullOr coercedTo str int;
  inherit (lib.lists) optionals optional;
  inherit (lib.meta) getExe';

  cfg = config.modules.system.sound.realtime;
in {
  options.modules.system.sound.realtime = {
    enable = mkEnableOption "Realtime sound optimizations.";

    alsaSeq = {
      enable =
        mkEnableOption "ALSA Sequencer kernel modules."
        // {
          default = true;
        };
    };

    soundcardPci = mkOption {
      type = nullOr str;
      # Might be able to default to an onboard?
      default = null;
      description = ''
               The PCI ID of your primary soundcard.

        To find the PCI ID of your soundcard(s) use:
                 'lspci | grep -i audio'
      '';
    };

    rtcqs = {
      enable = mkEnableOption "RealTime Config QuickScan package.";
      irq = mkOption {
        type = nullOr (coercedTo int toString str);
        default = null;
        description = ''
          The IRQ of the soundcard to allow rtcqs to check if it is busy.
        '';
      };
    };
  };
  config = mkIf (config.modules.system.sound.enable && cfg.enable) {
    boot = {
      kernel.sysctl = {
        "vm.swappiness" = 10;
      };

      kernelModules =
        []
        ++ optionals cfg.alsaSeq.enable ["snd-seq" "snd-rawmidi"];

      kernelParams = ["threadirqs"];

      postBootCommands = optionalString (cfg.soundcardPci != null) ''
               ${getExe' pkgs.pciutils "setpci"} -v -d *:* latency_timer=b0
        ${getExe' pkgs.pciutils "setpci"} -v -s ${cfg.soundcardPci} latency_timer=ff
      '';
    };
    # TODO wrap the bin name and with irq from options.
    environment.systemPackages = optional cfg.rtcqs.enable pkgs.real_time_config_quick_scan;
    environment.sessionVariables = let
      makeSearchPath' = subDir: (makeSearchPath subDir [
        "$HOME/.nix-profile/lib"
        "/run/current-system/sw/lib"
        "/etc/profiles/per-user/$USER/lib"
      ]);
    in {
      CLAP_PATH = mkDefault (makeSearchPath' "clap");
      DSSI_PATH = mkDefault (makeSearchPath' "dssi");
      LADSPA_PATH = mkDefault (makeSearchPath' "ladspa");
      LV2_PATH = mkDefault (makeSearchPath' "lv2");
      LXVST_PATH = mkDefault (makeSearchPath' "lxvst");
      VST3_PATH = mkDefault (makeSearchPath' "vst3");
      VST_PATH = mkDefault (makeSearchPath' "vst");
    };

    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = 99;
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = -11;
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "soft";
        value = 99999;
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "hard";
        value = 99999;
      }
    ];

    services.udev = {
      extraRules = ''
               KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };
  };
}
