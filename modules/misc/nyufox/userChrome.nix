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

  toPixels = x: "${toString x}px";
in ''
  body {
    background-color: ${background};
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
    margin: 8px !important;
    border: ${border-width} solid ${border};
    border-radius: ${border-rounding};
    &:not([sidebar-positionend]) {
      &[sidebar-launcher-expanded][sidebar-launcher-hovered]:not([sidebar-panel-open]),
      &[sidebar-ongoing-animations]:not([sidebar-launcher-expanded], [sidebar-panel-open]) {
        margin-inline-start: calc(var(--sidebar-launcher-collapsed-width) + 2 * 14px) !important;
      }
    }

    &[sidebar-positionend] {
      &[sidebar-launcher-expanded][sidebar-launcher-hovered]:not([sidebar-panel-open]),
      &[sidebar-ongoing-animations]:not([sidebar-panel-open], [sidebar-launcher-expanded]) {
        margin-inline-end: calc(var(--sidebar-launcher-collapsed-width) + 2 * 14px) !important;
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
    --toolbar-color: currentColor !important;
    --link-color: white !important;
    --urlbarView-highlight-background: var(--toolbar-field-background-color) !important;
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

    /* buttons */
    --toolbarbutton-hover-background: var(
      --tab-hover-background-color
    ) !important;
    --button-background-color-active: var(
      --tab-hover-background-color
    ) !important;

    /* opacity */
    --inactive-titlebar-opacity: 1 !important;
   }

  /* SIDEBAR */

  #sidebar-box {
    border-radius: ${border-rounding} !important;
    border: ${border-width} solid ${border};
    background: ${background} !important;
  }

  #sidebar {border-radius: ${border-rounding} !important;}

  #sidebar-header {display: none;}

  #sidebar-splitter {
    display: none;
  }

  /* TABS */

  #sidebar-main {
    margin: 8px 8px 0 8px !important;
    border-radius: ${border-rounding};
    border: ${border-width} solid ${border};
    background-color: ${background} !important;
    background-image: unset !important;
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
    box-shadow: unset !important;
  }

  .urlbarView {
    text-align: start;
    margin-top: 4px;
    background-color: ${background};
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
