{lib, ...}: let
  inherit (lib.modules) mkDefaultAttr;
  inherit (lib.lists) singleton;

in {
  imports = [
    # Default settings for wireplumber service.
    ./wireplumber
  ];

  services.pipewire.extraConfig = {
    pipewire = {
      # https://docs.pipewire.org/page_man_pipewire_conf_5.html
      "10-defaults" = mkDefaultAttr {
        "context.properties" = {
	  "clock.power-of-two-quantum" = true;
	  "core.daemon" = true;
	  # More buffers are worse latency and memory wise.
	  "link.max-buffers" = 16;
	};
        # Taken from the example
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
    };
    pipewire-pulse = {
      # https://docs.pipewire.org/page_man_pipewire-pulse_conf_5.html
      "10-defaults" = mkDefaultAttr {
        "pulse.rulse" = [
	  # Firefox marks capture streams as don't move.
	  { matches = [{"application.process.binary" = "firefox";}];
	    actions.quirks = ["remove-capture-dont-move"];
	  }
	  # Taken from example
	  # Speech dispatcher asks for too small latency and then underruns.
	  { matches = [{"application.name" = "~speech-dispatcher*";}];
	    actions = {
	      update-props = {
	        "pulse.min.req" = "1024/48000";
		"pulse.min.quantum" = "1024/48000";
	      };
	    };
	  }
	];

        "pulse.cmd" = [
	# Forces a sink to always be present, even if null.
        {cmd = "load-module"; args = "module-always-sink"; flags = [];}
	];
      };
    };
  };
}
