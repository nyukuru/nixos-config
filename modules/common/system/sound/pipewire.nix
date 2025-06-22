{
  lib, 
  ...
}: let
  inherit 
    (lib.modules)
    mkDefaultAttr
    ;

in {
  services.pipewire.wireplumber.extraConfig = {
    "10-defaults" = mkDefaultAttr {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
        "device.routes.default-sink-volume" = 1.0;
      };
      /*
      "context.properties" = {
        "clock.power-of-two-quantum" = true;
        "core.daemon" = true;
        "link.max-buffers" = 16;
        "log.level" = "D";
      };
      */
      "context.spa-libs" = {
        "audio.convert.*" = "audioconvert/libspa-audioconvert";
        "avb.*" = "avb/libspa-avb";
        "api.alsa.*" = "alsa/libspa-alsa";
        "api.v4l2.*" = "v4l2/libspa-v4l2";
        "api.libcamera.*" = "libcamera/libspa-libcamera";
        "api.bluez5.*" = "bluez5/libspa-bluez5";
        "api.vulkan.*" = "vulkan/libspa-vulkan";
        "api.jack.*" = "jack/libspa-jack";
        "support.*" = "support/libspa-support";
        "video.convert.*" = "videoconvert/libspa-videoconvert";
      };
    };
    "10-bluetooth" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              # Sony WH-1000XM4
              "device.product.id" = "0x0d58";
              "device.vendor.id" = "usb:054c";
            }
          ];
          actions = {
            update-props = {
              "bluez5.a2dp.ldac.quality" = "hq";
              "bluez5.auto-connect" = true;
              "bluez5.profile" = "a2dp-sink";
              "bluez5.roles" = ["a2dp_source" "a2dp_sink" "bap_sink" "bap_source"];
            };
          };
        }
      ];
    };
    "10-alsa" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              # Dell XPS 15 mic 
              "node.name" = "alsa_input.pci-0000_00_1f.3.analog-stereo";
            }
          ];
          actions = {
            update-props = {
              "channelmix.max-volume" = 0.35;
              "channelmix.normalize" = true;
            };
          };
        }
      ];
    };
  };

  services.pipewire.extraConfig = {
    pipewire-pulse = {
      # https://docs.pipewire.org/page_man_pipewire-pulse_conf_5.html
      "10-defaults" = mkDefaultAttr {
        "pulse.rules" = [
          # Firefox marks capture streams as don't move.
          {
            matches = [{"application.process.binary" = "firefox";}];
            actions.quirks = ["remove-capture-dont-move"];
          }
        ];

        "pulse.cmd" = [
          # Forces a sink to always be present, even if null.
          {
            cmd = "load-module";
            args = "module-always-sink";
            flags = [];
          }
        ];
      };
    };
  };
}
