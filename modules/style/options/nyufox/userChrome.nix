{ cfg }: let 

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

  browser {
    border-radius: ${border-rounding};
  }

  #tabbrowser-tabbox {
    margin: ${margin} !important;
    border: ${border-width} solid ${border};
    border-radius: ${border-rounding};
  }

  :root[inFullscreen="true"] #tabbrowser-tabbox {
    margin: 0 !important;
    border: none;
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
  .urlbar-page-action:not([hidden="true"]) {
    display: none;
  }

  #identity-box[pageproxystate="valid"] {
    &.verifiedDomain {
      #permissions-granted-icon + box:has(image[sharing="true"]) {
	margin-left: -4px;
      }
      #identity-icon {
	list-style-image: unset !important;
      }
    }
    &.mixedActiveBlocked {
      #permissions-granted-icon + box:has(image[sharing="true"]) {
	margin-left: -4px;
      }
    }
  }

  #navigator-toolbox {border-bottom: 2px !important;}

  #nav-bar {
    margin: ${margin} ${margin} 0;
    padding: 4px !important;
    border-radius: ${border-rounding} !important;
    border: ${border-width} solid ${border} !important;
    background: ${background} !important;
    transition: margin-left 0.2s ease !important;
    &:not([urlbar-exceeds-toolbar-bounds]) {overflow: unset !important;}
  }

  body:has(#sidebar-box:not([hidden="true"])) #nav-bar {
    margin-left: calc(60px + (${margin} * 2));
  }

  body:has(#sidebar-box:hover) #nav-bar {
    margin-left: calc(248px + (${margin} * 2)) !important;
  }

  /* OVERWRITES */
  ::-moz-selection {
    background-color: ${border} !important;
  }

  :root {
    --toolbar-color: currentColor !important;
    --link-color: ${border-width} !important;
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

  /* SIDEBAR */

  #sidebar-box {
    z-index: 1000;
    position: relative;
    min-width: 0 !important;
    max-width: none !important;
    width: 60px !important;
    transition: width 0.2s ease;
    margin-top: calc((var(--urlbar-toolbar-height) + ((${margin} + ${border-width}) * 2)) * -1) !important;
    &:hover {width: 248px !important;}

    margin: ${margin} 0 ${margin} ${margin};
    border-radius: ${border-rounding} !important;
    border: ${border-width} solid ${border};
    background: ${background} !important;
  }

  #sidebar {
    border-radius: ${border-rounding} !important;
  }

  #sidebar-header {
    display: none;
  }

  #sidebar-splitter {
    display: none;
  }

  @media (-moz-bool-pref: "sidebar.revamp") {
    #sidebar {box-shadow: none !important;}
    #sidebar-main {
      :root[lwtheme] & {
	background-color: ${background} !important;
	background-image: unset !important;
      }
    }
    #sidebar-box {font-size: unset !important;}
    }

    .tools-and-extensions {display: none !important;}

    #tabbrowser-tabs[orient="vertical"] &:not([expanded]) {
      #vertical-pinned-tabs-container, .tab-stack {
	width: 100% !important;
      }
    }
  }

  /* TABS */

  box#vertical-tabs {
    margin: 8px !important;
    border-radius: ${border-rounding};
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
''
