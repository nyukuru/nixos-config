{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {
      nyu.iso.limine.defaultLabel = "NyuOS Graphical Installer";
      nyu.iso.limine.specialisationOrder = [
        "NyuOS Manual Installer"
        "NyuOS Ephemeral"
      ];

      specialisation = {
        "NyuOS Manual Installer".configuration = {
          config,
          lib,
          ...
        }: {
          nyu.programs.niri.enable = lib.mkForce false;
          nyu.boot.greetd.autologin.command = lib.mkForce (lib.getExe config.users.users.${config.nyu.boot.greetd.autologin.user}.shell);
        };

        "NyuOS Ephemeral".configuration = {
          users.motd = lib.mkForce "";
        };
      };
    }

    (lib.mkIf (config.specialisation != {}) {
      environment.systemPackages = [
        pkgs.branding.calamares-carbon
        pkgs.scripts.calamares-launcher
        pkgs.networkmanagerapplet
      ];

      nyu.services.wayle.enable = lib.mkForce false;

      programs.niri.settings = {
        spawn-at-startup = [{argv = ["${pkgs.scripts.calamares-launcher}/bin/calamares-launcher"];}];
        window-rules = [
          {
            matches = [{app-id = "^calamares$";}];
            open-floating = true;
          }
        ];
        binds."Mod+I" = lib.mkForce {
          action.spawn = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
        };
      };
    })
  ];
}
