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
    --toolbar-color: currentColor !important;
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
    --tab-selected-bgcolor: color-mix(
      in hsl,
      var(--toolbar-field-color) 8%,
      var(--toolbar-bgcolor)
    ) !important;
    --tab-hover-background-color: color-mix(
      in hsl,
      var(--toolbar-field-color) 4%,
      var(--toolbar-bgcolor)
    ) !important;
    --tab-min-height: 29px !important;

    /* buttons */
    --toolbarbutton-hover-background: var(
      --tab-hover-background-color
    ) !important;
    --button-background-color-active: var(
      --tab-hover-background-color
    ) !important;
  }
''
