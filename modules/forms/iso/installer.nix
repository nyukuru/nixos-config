{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [
    pkgs.scripts.installer
  ];

  # The live medium's root is ephemeral, so every boot gets a clean
  # nixos-config to edit - any changes made during a session are gone
  # by the next boot.
  systemd.services.nixos-config-seed = {
    description = "Seed each user's home with nixos-config";
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.scripts.nixos-config-seed}";
    };
  };

  users.motd = lib.mkDefault ''
    nixos-config is at ~/nixos-config, freshly reset from this image every
    boot. Edit hosts/<hostname> there, then run:
      installer .#<hostname>
    to disko, install, and copy nixos-config onto its disk(s).
  '';
}
