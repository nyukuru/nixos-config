{
  lib,
  writeShellScript,
  wl-clipboard,
  libnotify,
  coreutils,
  slurp,
  grim,
  niri,
  jq,
}: let
  notify-send = lib.getExe libnotify;
  wl-copy = lib.getExe' wl-clipboard "wl-copy";
  mkdir = lib.getExe' coreutils "mkdir";
  date = lib.getExe' coreutils "date";
in
  writeShellScript "niri-screenshot" ''
    function usage {
      cat <<EOF
    Usage: $0 [options] <target> [directory]

    Options:
      -h, --help      Show this help message and exit.

    Arguments:
      <target>        What to capture, either "screen" (the focused output)
                      or "area" (a region selected with the mouse).
      [directory]     Where to save the screenshot,
                      defaults to ~/Pictures/Screenshots.
    EOF
    }

    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
      usage
      exit 0
    fi

    if [[ -z "$1" ]]; then
      echo "Error: No target provided."
      usage
      exit 1
    fi

    case "$1" in
      screen)
        OUTPUT="$(${lib.getExe' niri "niri"} msg --json focused-output | ${lib.getExe jq} -r '.name')"
        GRIM_ARGS=(-o "$OUTPUT")
        ;;
      area)
        GEOMETRY="$(${lib.getExe slurp})" || exit 1
        GRIM_ARGS=(-g "$GEOMETRY")
        ;;
      *)
        echo "Error: Unknown target '$1'."
        usage
        exit 1
        ;;
    esac

    DIRECTORY="''${2:-$HOME/Pictures/Screenshots}"
    FILE="$DIRECTORY/$(${date} '+%Y-%m-%d:%H-%M-%S').png"

    ${mkdir} -p "$DIRECTORY"
    ${lib.getExe grim} "''${GRIM_ARGS[@]}" "$FILE" || exit 1

    ${wl-copy} --type image/png < "$FILE"
    ${notify-send} -t 2000 -r 4550 -i "$FILE" "Screenshot" "Saved to $FILE"
  ''
