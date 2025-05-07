{
  lib,
  writeShellScript,
  wireplumber,
  libnotify,
}: let

  wpctl = "${wireplumber}/bin/wpctl";

in writeShellScript "volume" ''
  function usage {
    cat <<EOF
  Usage: $0 [options] <wpctl args>

  Options:
    -h, --help      Show this help message and exit.

  Arguments:
    <wpctl args>    Arguments passed to wpctl (e.g., set-mute @DEFAULT_SINK@ toggle).
  EOF
  }

  function notify_cmd {
    read volume mute <<< "$(get_volume)"
    ${lib.getExe libnotify} -e -t 500 -r 4560 --hint=int:value:"$volume" "🔊  $volume% $mute"
  }

  function get_volume {
    ${wpctl} get-volume "$ID" | awk -F'[: ]+' '{gsub(/\./,"",$2); print int($2)" "$3}'
  }

  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    usage  
    exit 0
  fi

  if [[ $# -gt 3 ]]; then
    echo "Error: Insuficient amount of arguments."
    usage
    exit 1
  fi

  ID="$2"

  ${wpctl} $@; notify_cmd
''
