{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  inherit (lib.strings) concatStringsSep optionalString;
  inherit (lib.modules) mkForce;
  inherit (lib.options) mkOption;
  inherit (lib.attrsets) mapAttrsToList attrNames;
  inherit (lib.types) listOf nullOr str;
  inherit (lib.lists) optional;
  inherit (builtins) baseNameOf;

  limineCd = pkgs.limine.override {buildCDs = true;};

  limineCfg = config.boot.loader.limine;
  style = limineCfg.style;

  timeout =
    if config.boot.loader.timeout == null
    then "no"
    else toString config.boot.loader.timeout;

  defaultLabel = config.nyu.iso.limine.defaultLabel;
  specialisationOrder = config.nyu.iso.limine.specialisationOrder;

  mkEntry = label: cfg: let
    kernelImage = "/boot/" + (cfg.boot.kernelPackages.kernel + "/" + cfg.system.boot.loader.kernelFile);
    initrdImage = "/boot/" + (cfg.system.build.initialRamdisk + "/" + cfg.system.boot.loader.initrdFile);

    cmdline = concatStringsSep " " (
      ["init=${cfg.system.build.toplevel}/init"] ++ cfg.boot.kernelParams
    );
  in ''
    /${label}
      protocol: linux
      path: boot():${kernelImage}
      module_path: boot():${initrdImage}
      cmdline: ${cmdline}
  '';

  entries = concatStringsSep "\n" (
    optional (defaultLabel != null) (mkEntry defaultLabel config)
    ++ map (name: mkEntry name config.specialisation.${name}.configuration) specialisationOrder
  );

  wallpaperTarget = path: "/limine/wallpapers/" + baseNameOf "${path}";

  styleLine = name: value:
    optionalString (value != null) "${name}: ${
      if builtins.isBool value
      then
        (
          if value
          then "yes"
          else "no"
        )
      else toString value
    }\n";

  styleLines = concatStringsSep "" [
    (concatStringsSep "" (map (w: "wallpaper: boot():${wallpaperTarget w}\n") style.wallpapers))
    (styleLine "wallpaper_style" style.wallpaperStyle)
    (styleLine "backdrop" style.backdrop)
    (styleLine "interface_resolution" style.interface.resolution)
    (styleLine "interface_branding" style.interface.branding)
    (styleLine "interface_branding_colour" style.interface.brandingColor)
    (styleLine "interface_help_colour" style.interface.helpColor)
    (styleLine "interface_help_colour_bright" style.interface.helpColorBright)
    (styleLine "interface_help_hidden" style.interface.helpHidden)
    (styleLine "term_font_scale" style.graphicalTerminal.font.scale)
    (styleLine "term_font_spacing" style.graphicalTerminal.font.spacing)
    (styleLine "term_palette" style.graphicalTerminal.palette)
    (styleLine "term_palette_bright" style.graphicalTerminal.brightPalette)
    (styleLine "term_foreground" style.graphicalTerminal.foreground)
    (styleLine "term_background" style.graphicalTerminal.background)
    (styleLine "term_foreground_bright" style.graphicalTerminal.brightForeground)
    (styleLine "term_background_bright" style.graphicalTerminal.brightBackground)
    (styleLine "term_margin" style.graphicalTerminal.margin)
    (styleLine "term_margin_gradient" style.graphicalTerminal.marginGradient)
  ];

  limineConf = pkgs.writeText "limine.conf" ''
    timeout: ${timeout}
    ${limineCfg.extraConfig}
    ${styleLines}
    ${entries}
    ${limineCfg.extraEntries}
  '';

  additionalFileEntries =
    mapAttrsToList (dest: source: {
      inherit source;
      target = "/limine/" + dest;
    })
    limineCfg.additionalFiles;

  wallpaperEntries =
    map (w: {
      source = w;
      target = wallpaperTarget w;
    })
    style.wallpapers;
in {
  options.nyu.iso.limine = {
    defaultLabel = mkOption {
      type = nullOr str;
      default = null;
      description = "Label for a limine boot menu entry for the un-specialised (default) config; omitted if null.";
    };

    specialisationOrder = mkOption {
      type = listOf str;
      default = attrNames config.specialisation;
      description = "Order (and labels) of specialisations shown as limine boot menu entries.";
    };
  };

  config = {
    isoImage = {
      contents =
        [
          {
            source = pkgs.emptyDirectory;
            target = "/isolinux";
          }
          {
            source = "${limineCd}/share/limine/limine-bios-cd.bin";
            target = "/boot/limine/limine-bios-cd.bin";
          }
          {
            source = "${limineCd}/share/limine/limine-bios.sys";
            target = "/boot/limine/limine-bios.sys";
          }
          {
            source = "${limineCd}/share/limine/limine-uefi-cd.bin";
            target = "/boot/limine/limine-uefi-cd.bin";
          }
          {
            source = "${limineCd}/share/limine/BOOTX64.EFI";
            target = "/EFI/BOOT/BOOTX64.EFI";
          }
          {
            source = limineConf;
            target = "/boot/limine/limine.conf";
          }
        ]
        ++ additionalFileEntries
        ++ wallpaperEntries;
    };

    system.build.image = mkForce config.system.build.isoImage;
    system.build.isoImage = mkForce (pkgs.callPackage "${modulesPath}/../lib/make-iso9660-image.nix" {
      inherit (config.isoImage) compressImage volumeID contents squashfsCompression;
      isoName = "${config.image.baseName}.iso";

      bootable = true;
      bootImage = "/boot/limine/limine-bios-cd.bin";

      efiBootable = true;
      efiBootImage = "/boot/limine/limine-uefi-cd.bin";

      usbBootable = true;
      isohybridMbrImage = "${pkgs.syslinux}/share/syslinux/isohdpfx.bin";

      squashfsContents = config.isoImage.storeContents;
    });
  };
}
