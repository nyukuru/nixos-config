{cfg}: let
  inherit
    (cfg.color)
    background
    border
    ;

  font-family = cfg.font.family;
  font-size = toPixels cfg.font.size;

  border-width = toPixels cfg.border.width;
  border-rounding = toPixels cfg.border.rounding;

  margin = toPixels cfg.margin;
  # --sidebar-launcher-collapsed-width is measured on #sidebar-container,
  # which already includes its border
  launcher-reserved = toPixels (2 * cfg.margin);

  toPixels = x: "${toString x}px";
in ''
  body {
    background-color: ${background} !important;
  }

  * {
    font-family: ${font-family};
    font-size: ${font-size};
  }

  ::placeholder {
    text-transform: lowercase;
  }

  /* BROWSER */

  .browserContainer {
    background: ${background};
  }

  #browser {
    border-radius: ${border-rounding};
    background-color: ${background} !important;
  }

  #browser:not(.browser-toolbox-background) {
    :root[lwtheme] & {
      background-color: var(--lwt-accent-color) !important;
      background-image: var(--lwt-accent-color) !important;
    }
  }

  #tabbrowser-tabbox {
    margin: ${margin} !important;
    border: ${border-width} solid ${border};
    border-radius: ${border-rounding};
    &:not([sidebar-positionend]) {
      &[sidebar-launcher-expanded][sidebar-launcher-hovered]:not([sidebar-panel-open]),
      &[sidebar-ongoing-animations]:not([sidebar-launcher-expanded], [sidebar-panel-open]) {
        margin-inline-start: calc(var(--sidebar-launcher-collapsed-width) + ${launcher-reserved}) !important;
      }
    }

    &[sidebar-positionend] {
      &[sidebar-launcher-expanded][sidebar-launcher-hovered]:not([sidebar-panel-open]),
      &[sidebar-ongoing-animations]:not([sidebar-panel-open], [sidebar-launcher-expanded]) {
        margin-inline-end: calc(var(--sidebar-launcher-collapsed-width) + ${launcher-reserved}) !important;
      }
    }
  }

  /* FINDBAR */

  findbar {
    background: ${background} !important;
    padding: 8px 0 !important;
    border-top: ${border-width} solid ${border} !important;
    border-radius: ${border-rounding};
  }

  .findbar-textbox {
    border: ${border-width} solid ${border} !important;
    background: ${background} !important;
  }

  .findbar-container > checkbox {
    text-transform: lowercase;
  }

  /* MENUS */

  menupopup, panel {
    --panel-background: ${background} !important;
    --panel-border-radius: ${border-rounding} !important;
    --panel-border-color: ${border} !important;
  }

  slot[part="content"] {border-width: 2px !important;}

  #appMenu-popup #shadow-root > * {border-width: 2px !important;}

  menu, menuitem {background: ${background} !important;}
  menuitem {border-radius: ${border-rounding} !important;}
  .menupopup-arrowscrollbox {border-width: 2px !important;}

  /* NAVBAR */

  * {
    --urlbar-toolbar-height: 32px !important;
    --urlbar-containter-height: 32px !important;
  }

  #userContext-icons,
  #translations-button-icon,
  #tracking-protection-icon-container,
  #star-button-box,
  #back-button,
  #forward-button,
  #sidebar-button,
  .urlbar-page-action:not([hidden="true"]) {
    display: none;
  }

  #navigator-toolbox {
    border-bottom: 2px !important;
    background-color: ${background} !important;
  }

  #nav-bar {
    margin: ${margin} ${margin} 0;
    padding: 4px !important;
    border-radius: ${border-rounding} !important;
    border: ${border-width} solid ${border} !important;
    background: ${background} !important;
    &:not([urlbar-exceeds-toolbar-bounds]) {overflow: unset !important;}
  }

  /* OVERWRITES */
  ::-moz-selection {
    background-color: ${border} !important;
  }

  :root {
    --toolbar-text-color: currentColor !important;
    --link-color: white !important;
    --urlbarView-highlight-background: color-mix(
      in hsl,
      var(--toolbar-field-text-color) 8%,
      var(--toolbar-background-color)
    ) !important;
    --urlbarView-highlight-color: var(--toolbar-field-text-color) !important;
    --toolbox-non-lwt-bgcolor: ${background} !important;
    --toolbox-non-lwt-bgcolor-inactive: ${background} !important;
    --focus-outline-color: transparent !important;

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

    /* buttons */
    --toolbarbutton-background-color-hover: var(
      --tab-background-color-hover
    ) !important;
    --button-background-color-active: var(
      --tab-background-color-hover
    ) !important;

    /* opacity */
    --inactive-titlebar-opacity: 1 !important;
   }

  /* SIDEBAR */

  #sidebar-box {
    border-radius: ${border-rounding} !important;
    border: ${border-width} solid ${border};
    background: ${background} !important;
    padding-inline-end: var(--space-small);

    &[sidebar-positionend] {
      padding-inline: 0;
      margin-inline-start: var(--space-small);
    }
  }

  #sidebar {border-radius: ${border-rounding} !important;}

  #sidebar-header {display: none;}

  #sidebar-splitter {
    display: none;
  }

  /* overlap the launcher splitter with the sidebar, as esr 140 did */
  #sidebar-launcher-splitter {
    margin-inline: calc(-1 * var(--splitter-width)) 0;

    #sidebar-container[sidebar-positionend] + & {
      margin-inline: 0 calc(-1 * var(--splitter-width));
    }
  }

  /* TABS */

  #sidebar-container {
    margin-block: ${margin} !important;
    margin-inline: ${margin} 0 !important;
    border-radius: ${border-rounding} !important;
    border: ${border-width} solid ${border} !important;
    background-color: ${background} !important;
    background-image: unset !important;

    &[sidebar-positionend] {margin-inline: 0 ${margin} !important;}
  }

  #browser:has(#sidebar-container[sidebar-ongoing-animations]) {
    clip-path: inset(0 0 0 ${margin});

    &::after {
      content: "";
      position: absolute;
      z-index: calc(var(--browser-area-z-index-sidebar-expand-on-hover) + 1);
      pointer-events: none;
      inset-block: ${margin};
      inset-inline-start: ${margin};
      width: calc(${border-rounding} + ${border-width});
      border: ${border-width} solid ${border};
      border-inline-end: none;
      border-start-start-radius: ${border-rounding};
      border-end-start-radius: ${border-rounding};
    }

    &:has(#sidebar-container[sidebar-positionend]) {
      clip-path: inset(0 ${margin} 0 0);

      &::after {
        inset-inline: auto ${margin};
        border-inline-start: none;
        border-inline-end: ${border-width} solid ${border};
        border-start-start-radius: 0;
        border-end-start-radius: 0;
        border-start-end-radius: ${border-rounding};
        border-end-end-radius: ${border-rounding};
      }
    }
  }

  #tabbrowser-tabs[orient="vertical"] &:not([expanded]) {
    #vertical-pinned-tabs-container, .tab-stack {
      width: 100% !important;
    }
  }

  #tabs-newtab-button {
    display: none !important;
  }

  /* hide window controls */
  .titlebar-buttonbox-container {display: none;}

  #TabsToolbar {display: none;}

  :root:not([privatebrowsingmode], [firefoxviewhidden])
    :is(toolbarbutton, toolbarpaletteitem)
    + #tabbrowser-tabs,
  :root[privatebrowsingmode]:not([firefoxviewhidden])
    :is(
      toolbarbutton:not(#firefox-view-button),
      toolbarpaletteitem:not(#wrapper-firefox-view-button)
    )
  + #tabbrowser-tabs {
    border-inline-start: none !important;
    padding-inline-start: 0 !important;
  }

  .toolbar-items {margin: 3px;}

  /* URLBAR */

  #urlbar {text-align: center;}
  #urlbar-searchmode-switcher {display: none !important}

  #urlbar-background {
    background-color: transparent !important;
    border: unset !important;
    border-radius: ${border-rounding} !important;
    box-shadow: unset !important;
  }

  .urlbarView {
    text-align: start;
    margin-top: 4px;
    background-color: ${background};
    border: ${border-width} solid ${border} !important;
    border-radius: 0 0 ${border-rounding} ${border-rounding};
  }
  .urlbarView-body-inner {
    #urlbar[open] > .urlbarView > .urlbarView-body-outer > & {
      border-top: unset !important;
    }
  }

  .urlbarView:not([noresults]) > .search-one-offs:not([hidden]) {
    border-top: ${border-width} solid ${border} !important;
  }

  .urlbar-input-container>box:not(#tracking-protection-icon-container) {display: none !important;}
''
