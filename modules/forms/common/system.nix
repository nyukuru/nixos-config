{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkDefault
    mkForce
    ;

  inherit
    (lib.meta)
    getExe
    getExe'
    ;

  inherit (config.style) colors;

  GB = x: toString (x * 1024 * 1024 * 1024);
in {
  hardware.enableRedistributableFirmware = true;

  boot = {
    consoleLogLevel = mkDefault 3;
    tmp.cleanOnBoot = !config.boot.tmp.useTmpfs;

    initrd = {
      verbose = mkDefault false;
      systemd = {
        enable = mkDefault true;

        # some emergency tooling
        storePaths = with pkgs; [
          util-linux
          cryptsetup
          sbctl
        ];

        extraBin = {
          fdisk = getExe' pkgs.util-linux "fdisk";
          lsblk = getExe' pkgs.util-linux "lsblk";
          sbctl = getExe pkgs.sbctl;
          cryptsetup = getExe pkgs.cryptsetup;
        };
      };

      availableKernelModules = [
        "aesni_intel"
        "cryptd"
        "usb_storage"
      ];

      kernelModules = [
        "btrfs"
        "nvme"
        "tpm"
        "sd_mod"
        "dm_mod"
        "ahci"
        "vfat"
      ];
    };

    kernelPackages = mkDefault pkgs.linuxPackages_latest;
    kernelParams = [
      "pti=auto"
      "idle=nowait"
      "iommu=pt"
      "acpi_backlight=native"
      "luks.options=timeout=0"
      "rd.luks.options=timeout=0"
      "rootflags=x-systemd.device-timeout=0"

      "fbcon=nodefer"
      "vt.global_cursor_default=0"
      "logo.nologo"
      "boot.shell_on_fail"
    ];

    kernel.sysctl = {
      # Hide kernel pointers from processes without the CAP_SYSLOG capability.
      #"kernel.kptr_restrict" = mkDefault 1;
      #"kernel.printk" = mkDefault "3 3 3 3";
      # Restrict loading TTY line disciplines to the CAP_SYS_MODULE capability.
      "dev.tty.ldisc_autoload" = mkDefault 0;
      # Make it so a user can only use the secure attention key which is required to access root securely.
      "kernel.sysrq" = mkDefault 4;
      # Protect against SYN flooding.
      "net.ipv4.tcp_syncookies" = mkDefault 1;
      # Protect against time-wait assasination.
      "net.ipv4.tcp_rfc1337" = mkDefault 1;

      # Enable strict reverse path filtering (that is, do not attempt to route
      # packets that "obviously" do not belong to the iface's network; dropped
      # packets are logged as martians).
      "net.ipv4.conf.all.log_martians" = mkDefault true;
      "net.ipv4.conf.all.rp_filter" = mkDefault "1";
      "net.ipv4.conf.default.log_martians" = mkDefault true;
      "net.ipv4.conf.default.rp_filter" = mkDefault "1";

      # Protect against SMURF attacks and clock fingerprinting via ICMP timestamping.
      "net.ipv4.icmp_echo_ignore_all" = mkDefault "1";

      # Ignore incoming ICMP redirects (note: default is needed to ensure that the
      # setting is applied to interfaces added after the sysctls are set)
      "net.ipv4.conf.all.accept_redirects" = mkDefault false;
      "net.ipv4.conf.all.secure_redirects" = mkDefault false;
      "net.ipv4.conf.default.accept_redirects" = mkDefault false;
      "net.ipv4.conf.default.secure_redirects" = mkDefault false;
      "net.ipv6.conf.all.accept_redirects" = mkDefault false;
      "net.ipv6.conf.default.accept_redirects" = mkDefault false;

      # Ignore outgoing ICMP redirects (this is ipv4 only)
      "net.ipv4.conf.all.send_redirects" = mkDefault false;
      "net.ipv4.conf.default.send_redirects" = mkDefault false;

      # Restrict abritrary use of ptrace to the CAP_SYS_PTRACE capability.
      "kernel.yama.ptrace_scope" = mkDefault 2;
      "net.core.bpf_jit_enable" = mkDefault false;
      "kernel.ftrace_enabled" = mkDefault false;
    };

    # Security
    blacklistedKernelModules = [
      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"
      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "vivid"
      "gfs2"
      "ksmbd"
      "nfsv4"
      "nfsv3"
      "cifs"
      "nfs"
      "cramfs"
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "squashfs"
      "udf"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
    ];
  };

  security = {
    protectKernelImage = mkDefault true;
    lockKernelModules = mkDefault false;
    forcePageTableIsolation = mkDefault true;

    apparmor = {
      enable = mkDefault true;
      killUnconfinedConfinables = mkDefault true;
      packages = [pkgs.apparmor-profiles];
    };
  };

  environment = {
    defaultPackages = mkForce (with pkgs; [
      # Network transfers.
      curl
      wget
      rsync
      git
      cifs-utils
      sbctl

      vim
    ]);

    variables = {
      SUDO_EDITOR = "vim";
      EDITOR = "vim";
      VISUAL = "vim";
      BROWSER = "firefox";
    };

    shellAliases = {
      nr = "nix-store --verify; ${getExe pkgs.nh} os switch -a";
      nru = "nix-store --verify; ${getExe pkgs.nh} os switch -au";
      gc = "${getExe pkgs.nh} clean all -ak 5";

      cp = "cp -i";

      ls = "ls -l";
      la = "ls -la";

      pls = "sudo";
      gis = "git status";
    };

    loginShellInit = ''
      if [ "$TERM" = "linux" ]; then
        echo -en "\e]P0${colors.base0}"
        echo -en "\e]P1${colors.base1}"
        echo -en "\e]P2${colors.base2}"
        echo -en "\e]P3${colors.base3}"
        echo -en "\e]P4${colors.base4}"
        echo -en "\e]P5${colors.base5}"
        echo -en "\e]P6${colors.base6}"
        echo -en "\e]P7${colors.base7}"

        echo -en "\e]P8${colors.base8}"
        echo -en "\e]P9${colors.base9}"
        echo -en "\e]PA${colors.baseA}"
        echo -en "\e]PB${colors.baseB}"
        echo -en "\e]PC${colors.baseC}"
        echo -en "\e]PD${colors.baseD}"
        echo -en "\e]PE${colors.baseE}"
        echo -en "\e]PF${colors.baseF}"
        clear
      fi
    '';
  };

  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  time = {
    timeZone = mkDefault "America/New_York";
    hardwareClockInLocalTime = true;
  };

  fonts = {
    packages = with pkgs; [
      # Typical fonts
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      # Symbol fonts
      nerd-fonts.symbols-only
      twemoji-color-font
      material-icons

      # Programming fonts
      jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = mkDefault rec {
        emoji = ["Twitter Color Emoji" "Symbols Nerd Font" "Material Icons Sharp"];
        monospace = ["JetBrains Mono" "Noto Sans Mono"] ++ emoji;
        sansSerif = ["JetBrains Mono" "Noto Sans"] ++ emoji;
        serif = ["Noto Serif"] ++ emoji;
      };
    };
  };

  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline8x16.psf";
    packages = [pkgs.tamzen];
  };

  nixpkgs.config = {
    allowUnfree = mkForce true;
    allowBroken = mkDefault false;
    #enableParallelBuildingByDefault = true;
  };

  documentation = {
    enable = mkDefault true;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
    nixos.enable = mkDefault false;
    man.enable = mkDefault true;
  };

  nix = {
    package = mkDefault pkgs.lixPackageSets.latest.lix;
    daemonCPUSchedPolicy = mkDefault "idle";
    daemonIOSchedClass = mkDefault "idle";

    # Store Optimizer
    optimise = {
      automatic = mkDefault true;
      dates = mkDefault ["Tue,Thu,Sat"];
    };

    settings = {
      # https://nix.dev/manual/nix/2.18/command-ref/conf-file.html
      auto-optimise-store = mkDefault true;
      stalled-download-timeout = mkDefault 30;
      connect-timeout = mkDefault 10;
      allowed-users = ["root" "@wheel"];
      trusted-users = ["root" "@wheel"];

      # Free 5GB when less than 1GB is left.
      min-free = mkDefault (GB 1);
      max-free = mkDefault (GB 5);

      # Isolate builds, stop if something prevents that.
      sandbox = mkDefault true;
      sandbox-fallback = mkDefault false;

      # Gives some extra lines to the tail of log
      log-lines = mkDefault 20;

      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];

      # Silence nixpkgs lib's use of `or` as an identifier, deprecated in Lix.
      extra-deprecated-features = [
        "or-as-identifier"
      ];

      pure-eval = mkDefault false;
      warn-dirty = mkDefault false;
      accept-flake-config = mkDefault false;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;

    allowNoPasswordLogin = mkDefault false;
    enforceIdUniqueness = mkDefault true;

    mutableUsers = false;
  };
}
