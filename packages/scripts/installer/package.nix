{
  lib,
  writeShellScriptBin,
  coreutils,
  gnugrep,
  jq,
  nix,
  nixos-install-tools,
  disko,
  cryptsetup,
  systemd,
}: let
  mkdir = lib.getExe' coreutils "mkdir";
  cp = lib.getExe' coreutils "cp";
  grep' = lib.getExe gnugrep;
  jq' = lib.getExe jq;
  nix' = lib.getExe' nix "nix";
  nixosInstall = lib.getExe' nixos-install-tools "nixos-install";
  nixosEnter = lib.getExe' nixos-install-tools "nixos-enter";
  disko' = lib.getExe disko;
  cryptsetup' = lib.getExe cryptsetup;
  cryptenroll = lib.getExe' systemd "systemd-cryptenroll";
  luksTpmTargets = ./luks-tpm-targets.nix;
in
  writeShellScriptBin "installer" ''
    set -euo pipefail

    function usage {
      cat <<EOF
    Usage: $0 [options] <flake>#<hostname>

    Validates hosts/<hostname> in <flake> (build the toplevel closure), disko's
    the disk(s) declared in hosts/<hostname>/disk-config.nix, installs NixOS
    onto them, then copies nixos-config into every normal user's home
    directory on the newly installed system.

    Options:
      -h, --help    Show this help message and exit.
      --dry-run     Validate and show the disko plan without formatting,
                    installing, or copying anything.
      -y, --yes     Skip the "type yes to continue" confirmation before
                    destroying the disk(s). For non-interactive callers
                    (e.g. a Calamares job) that have already confirmed
                    elsewhere.

    Arguments:
      <flake>#<hostname>   e.g. .#carbon - "." resolves to the live
                            nixos-config checkout at $HOME/nixos-config.
                            hosts/<hostname>/disk-config.nix's disk(s)
                            will be ERASED.
    EOF
    }

    DRY_RUN=0
    SKIP_CONFIRM=0
    ARGS=()

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        --dry-run)
          DRY_RUN=1
          shift
          ;;
        -y|--yes)
          SKIP_CONFIRM=1
          shift
          ;;
        -*)
          echo "Error: Unknown option '$1'." >&2
          usage
          exit 1
          ;;
        *)
          ARGS+=("$1")
          shift
          ;;
      esac
    done

    if [[ ''${#ARGS[@]} -ne 1 ]] || [[ "''${ARGS[0]}" != *#* ]]; then
      echo "Error: Expected a single <flake>#<hostname> argument." >&2
      usage
      exit 1
    fi

    REF="''${ARGS[0]}"
    FLAKE_PATH="''${REF%%#*}"
    HOSTNAME="''${REF#*#}"

    if [[ "$FLAKE_PATH" == "." ]]; then
      FLAKE_PATH="$HOME/nixos-config"
    fi

    HOST_DIR="$FLAKE_PATH/hosts/$HOSTNAME"
    DISK_CONFIG="$HOST_DIR/disk-config.nix"

    if [[ ! -e "$HOST_DIR" ]]; then
      echo "Error: $HOST_DIR does not exist. Add hosts/$HOSTNAME to $FLAKE_PATH first." >&2
      exit 1
    fi

    if [[ ! -e "$DISK_CONFIG" ]]; then
      echo "Error: $DISK_CONFIG does not exist." >&2
      exit 1
    fi

    echo "Validating $FLAKE_PATH#$HOSTNAME (building its toplevel closure)..."
    TOPLEVEL="$(${nix'} build "$FLAKE_PATH#nixosConfigurations.$HOSTNAME.config.system.build.toplevel" --no-link --print-out-paths)"

    DISKO_ARGS=(--mode destroy,format,mount --yes-wipe-all-disks "$DISK_CONFIG")
    if [[ $DRY_RUN -eq 1 ]]; then
      DISKO_ARGS=(--dry-run "''${DISKO_ARGS[@]}")
    elif [[ $SKIP_CONFIRM -ne 1 ]]; then
      echo
      echo "About to destroy, format and mount the disk(s) declared in $DISK_CONFIG."
      read -r -p "Type 'yes' to continue: " CONFIRM
      if [[ "$CONFIRM" != "yes" ]]; then
        echo "Aborted."
        exit 1
      fi
    fi

    sudo ${disko'} "''${DISKO_ARGS[@]}"

    if [[ $DRY_RUN -eq 1 ]]; then
      exit 0
    fi

    sudo ${nixosInstall} --root /mnt --system "$TOPLEVEL" --no-root-password

    LUKS_TSV="$(
      ${nix'} eval --raw "$FLAKE_PATH#nixosConfigurations.$HOSTNAME.config.disko.devices.disk" \
        --apply "import ${luksTpmTargets}"
    )"

    while IFS=$'\t' read -r luks_name password_file; do
      [[ -z "$luks_name" ]] && continue
      if [[ -z "$password_file" ]]; then
        echo "Warning: LUKS device '$luks_name' requests TPM2 auto-unlock but has no passwordFile; skipping TPM enrollment." >&2
        continue
      fi

      luks_device="$(sudo ${cryptsetup'} status "$luks_name" | ${grep'} -oE '/dev/\S+' | head -n1 || true)"
      if [[ -z "$luks_device" ]]; then
        echo "Warning: could not resolve the underlying device for LUKS mapping '$luks_name'; skipping TPM enrollment." >&2
        continue
      fi

      echo "Enrolling $luks_device ('$luks_name') into the TPM so it unlocks automatically on boot..."
      if ! sudo ${cryptenroll} --tpm2-device=auto --unlock-key-file="$password_file" "$luks_device"; then
        echo "Warning: TPM2 enrollment failed for $luks_device; you'll need to enter the disk password at boot." >&2
      fi
    done <<<"$LUKS_TSV"

    USERS_TSV="$(
      ${nix'} eval --json "$FLAKE_PATH#nixosConfigurations.$HOSTNAME.config.users.users" \
        | ${jq'} -r 'to_entries[] | select(.value.isNormalUser) | "\(.key)\t\(.value.home)\t\(.value.group)"'
    )"

    while IFS=$'\t' read -r user home group; do
      [[ -z "$user" ]] && continue
      echo "Copying nixos-config to $user's home ($home) on the new system..."
      sudo ${mkdir} -p "/mnt$home"
      sudo ${cp} -r "$FLAKE_PATH" "/mnt$home/nixos-config"
      sudo ${nixosEnter} --root /mnt -c "chown -R $user:$group $home/nixos-config"
    done <<<"$USERS_TSV"

    echo
    echo "Installed $HOSTNAME. Reboot into the new system when ready."
  ''
