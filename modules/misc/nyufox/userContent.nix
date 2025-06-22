{cfg}: let
  inherit
    (cfg.color)
    background
    border
    ;

  font-size = toPixel cfg.font.size;
  font-family = cfg.font.family;

  border-width = toPixel cfg.border.width;
  border-rounding = toPixel cfg.border.width;

  margin = toPixel cfg.margin;

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

    /* containers */
    [data-color="yellow"],
    .identity-color-yellow {
      --color: #f6c177 !important;
      --identity-tab-color: #f6c177 !important;
      --identity-icon-color: #f6c177 !important;
    }
    [data-color="purple"],
    .identity-color-purple {
      --color: #c4a7e7 !important;
      --identity-tab-color: #c4a7e7 !important;
      --identity-icon-color: #c4a7e7 !important;
    }
    [data-color="blue"],
    .identity-color-blue {
      --color: #9ccfd8 !important;
      --identity-tab-color: #9ccfd8 !important;
      --identity-icon-color: #9ccfd8 !important;
    }
    [data-color="turquoise"],
    .identity-color-turquoise {
      --color: #9ccfd8 !important;
      --identity-tab-color: #9ccfd8 !important;
      --identity-icon-color: #9ccfd8 !important;
    }
    [data-color="green"],
    .identity-color-green {
      --color: #3e8fb0 !important;
      --identity-tab-color: #3e8fb0 !important;
      --identity-icon-color: #3e8fb0 !important;
    }
    [data-color="orange"],
    .identity-color-orange {
      --color: #f6c177 !important;
      --identity-tab-color: #f6c177 !important;
      --identity-icon-color: #f6c177 !important;
    }
    [data-color="red"],
    .identity-color-red {
      --color: #eb6f92 !important;
      --identity-tab-color: #eb6f92 !important;
      --identity-icon-color: #eb6f92 !important;
    }
    [data-color="pink"],
    .identity-color-pink {
      --color: #ea9a97 !important;
      --identity-tab-color: #ea9a97 !important;
      --identity-icon-color: #ea9a97 !important;
    }

    /* opacity */
    --inactive-titlebar-opacity: 1 !important;
  }

  @-moz-document regexp("^moz-extension://.*?/sidebar/sidebar.html")
  {
    /* wrap start */

    #root.root {
      --general-border-radius: ${border-rounding} !important;
      --general-margin: ${margin} !important;
      --tabs-font: ${font-size} ${font-family} !important;

      --button-size: 35px;
      --pin-favicon-size: 30px;

      --nav-btn-margin: calc(${margin} / 2) !important;
      --nav-btn-width: var(--button-size) !important;
      --nav-btn-height: var(--button-size) !important;
      --nav-btn-len-margin: calc(${border-rounding} / 4) !important;

      --audio-btn-round-margin: calc(${border-rounding} / 2) !important;

      --tabs-audio-btn-width: 22px !important;
      --tabs-margin: 6px !important;
      --tabs-height: var(--button-size) !important;
      --tabs-inner-gap: 6px !important;
      --tabs-border-radius: ${border-rounding} !important;

      --frame-bg: ${background} !important;
      --frame-el-overlay-selected-border: var(--s-toolbar-fg) !important;
      --frame-el-overlay-hover-bg: color-mix(
        in hsl,
        currentColor 4%,
        var(--toolbar-bg)
      ) !important;
      --toolbar-el-overlay-selected-border: var(--s-toolbar-fg) !important;
      --status-notice: var(--s-toolbar-fg) !important;
    }

    /*
     * ─[ pinned tabs ]──────────────────────────────────────────────────────
    */


    /*
     * ─[ general tab stuff ]────────────────────────────────────────────────
    */
    .Tab[data-active="true"] .body {
      box-shadow: none !important;
      background-color: ${border} !important;

      & .title {
        color: var(--s-popup-fg) !important;
      }
    }

    .Tab .body {
      text-transform: lowercase;
      & .title {
        transition: opacity 0.2s ease !important;
        color: color-mix(in hsl, var(--s-popup-fg) 50%, transparent) !important;
      }
      & .audio {transition: opacity 0.2s ease !important;}
      & .fav {
        left: 0;
        transition: all 70ms ease;
        filter: 
          grayscale(100%) 
          contrast(200%) 
          drop-shadow(1px 1px white)
      }
    }

    #root.root:not(:hover) .Tab .body {
      .title {opacity: 0 !important;}
      .audio {opacity: 0 !important;}
      .fav {
        left: 50%;
        transform: translateX(-50%) !important;
        transition: all 0.2s ease 128ms;
        margin: 0 !important;
      }
    }

    /*
     * ─[ other ]────────────────────────────────────────────────────────────
    */

    /* consistent navbar background */
    #nav_bar {
      background-color: transparent !important;
    }

    /* padding */
    #nav_bar {
      padding-top: var(--nav-btn-margin) !important;
      padding-bottom: var(--general-margin) !important;
    }

    .BottomBar {
      padding: var(--nav-btn-margin) !important;
    }

    /* popup */
    .popup {
      margin: var(--tabs-margin) !important;
    }
    .popup-container {
      background-color: transparent !important;
    }

    /* search */
    #search_bar {
      margin: 4px !important;
    }
    #search_bar[data-showed="false"] {
      display: none !important;
    }
    #search_bar .clear-btn {
      margin-inline-end: var(--general-margin);
    }

    .NavigationBar {
      box-shadow: none !important;
    }

    /* accent colored selection */
    ::selection {
      background: color-mix(
        in hsl,
        var(--s-toolbar-fg) 20%,
        transparent
      ) !important;
    }

    /* notification */
    .notification {
      border-radius: ${border-rounding} !important;
      &::after {
        top: calc(${border-rounding} / 4 + 3px) !important;
        right: calc(${border-rounding} / 4 + 3px) !important;
      }
    }
  } /* wrap end */
''
