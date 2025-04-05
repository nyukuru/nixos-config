{
  inputs,
  modulesPath,
  ...
}: {
  disabledModules = [ "${modulesPath}/programs/wayland/waybar.nix" ];
  imports = [ "${inputs.dev-nixpkgs-waybar}/nixos/modules/programs/wayland/waybar.nix" ];

  programs.waybar = {
    enable = true;

    settings = {
      layer = "top";

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];

      modules-center = [
        "clock"
      ];

      modules-right = [
        "battery"
      ];

      "sway/window".max-length = 50;

      battery = {
        format = "{capacity}% {icon}";
        format-icons = ["" "" "" "" ""];
      };

      clock = {
        format-alt = "{:%a, %d. %b  %H:%M}";
      };
    };
  };
}
