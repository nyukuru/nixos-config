{
  lib,
  writeShellScript,
  slurp,
  jq,
  sway-unwrapped,
}:
writeShellScript "sway-screencast-chooser" ''
  WINDOWS=$(${lib.getExe' sway-unwrapped "swaymsg"} -t get_tree | ${lib.getExe jq} -r '.. | select(.pid? and .visible?) | "\(.rect.x+.window_rect.x),\(.rect.y+.window_rect.y) \(.window_rect.width)x\(.window_rect.height) Window: \(.foreign_toplevel_identifier)"')
  OUTPUTS=$(${lib.getExe' sway-unwrapped "swaymsg"} -t get_outputs | ${lib.getExe jq} -r '.[] | {name} + .rect | "\(.x),\(.y) \(.width)x\(.height) Monitor: \(.name)"')

  echo -e "$WINDOWS\n$OUTPUTS" | ${lib.getExe slurp} -f "%l"
''
