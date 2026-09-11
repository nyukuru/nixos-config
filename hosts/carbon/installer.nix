{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.attrsets) filterAttrs mapAttrsToList;

  normalUsers = filterAttrs (_: u: u.isNormalUser) config.users.users;
in {
  environment.systemPackages = [
    pkgs.scripts.installer
  ];

  systemd.tmpfiles.rules =
    mapAttrsToList
    (name: u: "C ${u.home}/nixos-config - - ${name} ${u.group} - /nixos-config-snapshot")
    normalUsers;

  users.motd = lib.mkDefault ''
    nixos-config is at ~/nixos-config. Edit hosts/<hostname> there, then run:
      installer .#<hostname>
  '';
}
