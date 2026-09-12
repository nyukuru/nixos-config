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
        pkgs.branding.calamares-nyuos
        pkgs.scripts.calamares-launcher
        pkgs.nmgui
      ];

      systemd.tmpfiles.rules = [
        "d /etc/calamares 0755 ${config.nyu.boot.greetd.autologin.user} root -"
        "d /etc/calamares/modules 0755 ${config.nyu.boot.greetd.autologin.user} root -"
        "f /run/detected-hardware.json 0644 ${config.nyu.boot.greetd.autologin.user} root -"
      ];

      nyu.services.wayle.enable = lib.mkForce false;

      programs.niri.settings = {
        spawn-at-startup = [{argv = ["${pkgs.scripts.calamares-launcher}/bin/calamares-launcher"];}];
        window-rules = [
          {
            matches = [{app-id = "^io\\.calamares\\.calamares$";}];
            open-floating = true;
          }
          {
            matches = [{app-id = "^com\\.network\\.manager$";}];
            open-floating = true;
          }
        ];
        binds = {
          "Mod+I" = lib.mkForce {
            hotkey-overlay.title = "Open Network Manager";
            action.spawn = lib.getExe pkgs.nmgui;
          };

          "Super+Return".hotkey-overlay.title = lib.mkForce "Open Terminal";
          "Super+F".hotkey-overlay.title = lib.mkForce "Open Browser";
          "Super+Alt+L".hotkey-overlay.title = lib.mkForce "Lock Screen";
          "Mod+D".hotkey-overlay.title = lib.mkForce "Open Application Launcher";

          "Ctrl+Alt+Delete".hotkey-overlay.hidden = true;
          "Mod+Shift+H".hotkey-overlay.hidden = true;
          "Mod+Shift+L".hotkey-overlay.hidden = true;
          "Mod+U".hotkey-overlay.hidden = true;
          "Mod+Shift+U".hotkey-overlay.hidden = true;
          "Mod+Shift+I".hotkey-overlay.hidden = true;
          "Mod+R".hotkey-overlay.hidden = true;
          "Mod+Space".hotkey-overlay.hidden = true;
          "Mod+BracketLeft".hotkey-overlay.hidden = true;
          "Mod+BracketRight".hotkey-overlay.hidden = true;
          "Mod+V".hotkey-overlay.hidden = true;
          "Mod+Shift+V".hotkey-overlay.hidden = true;
          "Ctrl+Print".hotkey-overlay.hidden = true;
        };
      };
    })
  ];
}
