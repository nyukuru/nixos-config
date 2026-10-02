{
  lib,
  writeText,
}: let
  inherit
    (lib)
    all
    any
    attrNames
    concatMapStringsSep
    concatStringsSep
    filterAttrs
    hasPrefix
    isAttrs
    isList
    mapAttrsToList
    ;

  inherit (lib.generators) toKeyValue;
  inherit (lib.types) attrsOf bool float int listOf nullOr oneOf path str;
in {
  importantPrefixes ? ["$"],
}: let
  valueType =
    nullOr (oneOf [bool int float str path (attrsOf valueType) (listOf valueType)])
    // {description = "hyprlang (Hypr ecosystem) configuration value";};

  toHyprconf = attrs: let
    toHyprconf' = indent: attrs: let
      isImportantField = n: _: any (prev: hasPrefix prev n) importantPrefixes;
      importantFields = filterAttrs isImportantField attrs;
      withoutImportantFields = fields: removeAttrs fields (attrNames importantFields);

      allSections = filterAttrs (_n: v: isAttrs v || isList v) attrs;
      sections = withoutImportantFields allSections;

      mkSection = n: attrs:
        if isList attrs
        then let
          separator =
            if all isAttrs attrs
            then "\n"
            else "";
        in (concatMapStringsSep separator (a: mkSection n a) attrs)
        else if isAttrs attrs
        then ''
          ${indent}${n} {
          ${toHyprconf' "  ${indent}" attrs}${indent}}
        ''
        else toHyprconf' indent {${n} = attrs;};

      mkFields = toKeyValue {
        listsAsDuplicateKeys = true;
        inherit indent;
      };

      allFields = filterAttrs (_n: v: !(isAttrs v || isList v)) attrs;
      fields = withoutImportantFields allFields;
    in
      mkFields importantFields
      + concatStringsSep "\n" (mapAttrsToList mkSection sections)
      + mkFields fields;
  in
    toHyprconf' "" attrs;
in {
  type = attrsOf valueType;
  generate = name: attrs: writeText name (toHyprconf attrs);
}
