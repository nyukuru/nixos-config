{config, ...}: let
  inherit (config.style) colors;
in {
  environment.loginShellInit = ''
    if [ "$TERM" = "linux" ]; then
      echo -en "\e]P0${colors.base0}"
      echo -en "\e]P1${colors.base1}"
      echo -en "\e]P2${colors.base2}"
      echo -en "\e]P3${colors.base3}"
      echo -en "\e]P4${colors.base4}"
      echo -en "\e]P5${colors.base5}"
      echo -en "\e]P6${colors.base6}"
      echo -en "\e]P7${colors.base7}"

      echo -en "\e]P8${colors.base8}"
      echo -en "\e]P9${colors.base9}"
      echo -en "\e]PA${colors.baseA}"
      echo -en "\e]PB${colors.baseB}"
      echo -en "\e]PC${colors.baseC}"
      echo -en "\e]PD${colors.baseD}"
      echo -en "\e]PE${colors.baseE}"
      echo -en "\e]PF${colors.baseF}"
      clear
    fi
  '';
}
