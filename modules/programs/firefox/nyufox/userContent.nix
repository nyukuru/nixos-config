{cfg}: let
  inherit
    (cfg.color)
    background
    border
    ;

  font-family = cfg.font.family;
  border-rounding = toPixel cfg.border.width;

  toPixel = x: "${toString x}px";
in ''
  @-moz-document url-prefix(about:) {
    * {
      font-family: ${font-family} !important;
    }
  }

  :root {
    --toolbar-text-color: currentColor !important;
    --link-color: ${border} !important;
    --urlbarView-highlight-background: var(
      --toolbar-field-background-color
    ) !important;
    --toolbox-non-lwt-bgcolor: ${background} !important;

    /* borders */
    --border-width: 2px !important;
    --border-radius-small: ${border-rounding} !important;
    --border-radius-medium: ${border-rounding} !important;
    --toolbarbutton-border-radius: ${border-rounding} !important;
    --tab-border-radius: ${border-rounding} !important;

    /* tabs */
    --tab-selected-outline-color: transparent !important;
    --tab-background-color-selected: color-mix(
      in hsl,
      var(--toolbar-field-text-color) 8%,
      var(--toolbar-background-color)
    ) !important;
    --tab-background-color-hover: color-mix(
      in hsl,
      var(--toolbar-field-text-color) 4%,
      var(--toolbar-background-color)
    ) !important;
    --tab-min-height: 29px !important;

    /* buttons */
    --toolbarbutton-background-color-hover: var(
      --tab-background-color-hover
    ) !important;
    --button-background-color-active: var(
      --tab-background-color-hover
    ) !important;
  }
''
