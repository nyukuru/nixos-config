# Walks a `config.disko.devices.disk` value (passed in via `nix eval --apply`)
# and returns one "<luks name>\t<passwordFile>" line per LUKS device that asks
# for TPM2 auto-unlock and was formatted from a passwordFile. Plain builtins
# only, and internal (`_`-prefixed) disko implementation attrs are skipped, to
# avoid forcing evaluation of the non-JSON-able function values disko stores
# alongside its option values (e.g. `_pkgs`).
disks: let
  isInternal = name: builtins.substring 0 1 name == "_";

  hasTpm2 = opts: builtins.any (o: builtins.match ".*tpm2-device.*" o != null) opts;

  recurse = value:
    if builtins.isAttrs value
    then
      (
        if
          (value.type or null) == "luks"
          && (value.passwordFile or null) != null
          && hasTpm2 (value.settings.crypttabExtraOpts or [])
        then [(value.name + "\t" + value.passwordFile)]
        else []
      )
      ++ builtins.concatMap recurse (map (n: value.${n}) (builtins.filter (n: !isInternal n) (builtins.attrNames value)))
    else if builtins.isList value
    then builtins.concatMap recurse value
    else [];
in
  builtins.concatStringsSep "\n" (recurse disks)
