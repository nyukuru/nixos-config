{
  lib,
  writeShellScript,
  brightnessctl,
  libnotify,
}:
writeShellScript "brightness" ''
  function usage {
    cat <<EOF
  Usage: $0 [options] <brightness_value>

  Options:
    -h, --help      Show this help message and exit.

  Arguments:
    <brightness_value>   The brightness value to set (e.g., 50%+).
  EOF
  }

  notify_cmd(){
    ${lib.getExe libnotify} -e -t 500 -r 4570 --hint=int:value:"$(get_brightness)" "☀️  $(get_brightness)%"
  }

  get_brightness(){
    ${lib.getExe brightnessctl} i | grep -oP '\(\K[^%\)]+'
  }

  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    usage  
    exit 0
  fi

  if [[ -z "$1" ]]; then
    echo "Error: No brightness value provided."
    usage
    exit 1
  fi

  ${lib.getExe brightnessctl} s "$1"; notify_cmd
''
