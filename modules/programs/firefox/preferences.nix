{
  config,
  lib,
  ...
}: let
  inherit
    (lib.strings)
    concatMapAttrsStringSep
    optionalString
    substring
    toJSON
    ;

  inherit
    (builtins)
    hashFile
    ;

  combineHash = file1: file2: let
    hash1 = substring 0 8 (hashFile "md5" file1);
    hash2 = substring 0 8 (hashFile "md5" file2);
  in
    hash1 + hash2;

  cfg = config.nyu.programs.firefox;
in {
  nyu.programs.firefox.preferences =
    optionalString
    (cfg.userChrome != null && cfg.userContent != null) ''
         // Apply chrome folder
         let {FileUtils} = ChromeUtils.importESModule("resource://gre/modules/FileUtils.sys.mjs");
         var updated = false;

         // Create nsiFile objects
         var chromeDir = Services.dirsvc.get("ProfD", Components.interfaces.nsIFile);
         chromeDir.append("chrome");

         // XP_UNIX forces symlinks to be resolved when copying
         // so we are just going to normal copy from nix store
         var userChrome = new FileUtils.File("${cfg.userChrome}");
         var userContent = new FileUtils.File("${cfg.userContent}");

         // Combine hashes of both files
         var hashFile = chromeDir.clone();
         hashFile.append("${combineHash cfg.userChrome cfg.userContent}");

         if (!chromeDir.exists()) {
      chromeDir.create(Components.interfaces.nsIFile.DIRECTORY_TYPE, FileUtils.PERMS_DIRECTORY);
      updated = true;

         } else if (!hashFile.exists()) {
      chromeDir.remove(true);
      updated = true;
         }

         // Restart Firefox immediately if one of the files got updated
         if (updated === true) {
      userChrome.copyTo(chromeDir, "userChrome.css");
      userContent.copyTo(chromeDir, "userContent.css");

      // Write into storage the iteration of the config via hash
      hashFile.create(Components.interfaces.nsIFile.NORMAL_FILE_TYPE, 0b100100100);

      var appStartup = Components.classes["@mozilla.org/toolkit/app-startup;1"].getService(Components.interfaces.nsIAppStartup);
      appStartup.quit(Components.interfaces.nsIAppStartup.eForceQuit | Ci.nsIAppStartup.eRestart);
         }
    ''
    + optionalString (cfg.newtab != "") ''
      // Custom newtab
      ChromeUtils.importESModule("resource:///modules/AboutNewTab.jsm").AboutNewTab.newTabURL = "${cfg.newtab}";

      // Auto focus new tab content
      let {BrowserWindowTracker} = ChromeUtils.importESModule("resource:///modules/BrowserWindowTracker.sys.mjs");

      Services.obs.addObserver((event) => {
        window = BrowserWindowTracker.getTopWindow();
        window.gBrowser.selectedBrowser.focus();
        }, "browser-open-newtab-start");
    ''
    + (concatMapAttrsStringSep "\n"
      (name: value: "pref(\"${name}\", ${toJSON value});") {
        # Important resources:
        #  - https://webdevelopmentaid.wordpress.com/2013/10/21/customize-privacy-settings-in-mozilla-firefox-part-1-aboutconfig
        #  - https://panopticlick.eff.org
        #  - http://ip-check.info
        #  - http://browserspy.dk
        #  - https://wiki.mozilla.org/Fingerprinting
        #  - http://www.browserleaks.com
        #  - http://fingerprint.pet-portal.eu

        ## Styling
        # Enable Dark Theme Default
        "ui.systemUsesDarkTheme" = 1;

        # Disable Firefox View Button
        "browser.tabs.firefox-view" = false;

        "browser.toolbars.bookmarks.visibility" = "never";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-proprties.content.enabled" = true;

        # Shyfox icons when available
        "shyfox.enable.ext.mono.toolbar.icons" = true;
        "shyfox.enable.ext.mono.context.icons" = true;
        "shyfox.enable.context.menu.icons" = true;

        # Set startup page.
        #  - 0=blank
        #  - 1=home
        #  - 2=last visited page,
        #  - 3=resume previous session
        "browser.startup.page" = 0;

        # newtab page
        "browser.newtabpage.enabled" = false;

        # Disable using the OS's geolocation service
        "geo.provider.use_geoclue" = false;

        # Disable recommendation pane in about:addons
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;

        # Disable personalized Extension Recommendations in about:addons and AMO
        "browser.discovery.enable" = false;

        # Disable shopping experience
        "browser.shopping.experience2023.enabled" = false;

        ## Telemetry
        # Disable new data submission.
        "datareporting.policy.dataSubmissionEnabled" = false;

        # Disable Health Reports
        "datareporting.healthreport.uploadEnabled" = false;

        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;

        # Disable Telemetry Coverage
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";

        ## Studies
        # Disable Firefox Studies
        "app.shield.optoutstudies.enabled" = false;

        # Disable Normandy/Shield
        # Shield is a telemetry system that can push and test "recipes"
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";

        ## Other
        # Disable Captive Portal detection
        "captivedetect.canonicalURL" = "";
        "network.captive-portal-service.enabled" = false;

        # Disable Network Connectivity checks
        "network.connectivity-service.enabled" = false;

        ## Safe Browsing
        # Disable SafeBrowsing checks for downloads (remote)
        "browser.safebrowsing.downloads.remote.enabled" = false;

        ## Implicit Outbound
        "network.prefetch-next" = false;

        # Disable DNS prefetching
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;

        # Disable predictor / prefetching
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false; # default: false

        # Disable link-mouseover opening connection to linked server
        "network.http.speculative-parallel-limit" = 0;

        # Disable mousedown speculative connections on bookmarks and history
        "browser.places.speculativeConnect.enabled" = false;

        # Enforce no "Hyperlink Auditing" (click tracking)
        "browser.send_pings" = false;

        ##  DNS / DoH / PROXY / SOCKS
        # Set the proxy server to do any DNS lookups when using SOCKS
        "network.proxy.socks_remote_dns" = true;

        # Disable using UNC (Uniform Naming Convention) paths
        "network.file.disable_unc_paths" = true;

        # Disable GIO as a potential proxy bypass vector
        "network.gio.supported-protocols" = "";

        # Disable proxy direct failover for system requests (default: true)
        "network.proxy.failover_direct" = true;

        ## LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY / FORMS
        # Disable location bar making speculative connections
        "browser.urlbar.speculativeConnect.enabled" = false;

        # Disable location bar contextual suggestions
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.addons" = false;
        "browser.urlbar.suggest.quicksuggest.bookmark" = false;
        "browser.urlbar.suggest.quicksuggest.calculator" = false;
        "browser.urlbar.suggest.quicksuggest.engines" = false;
        "browser.urlbar.suggest.quicksuggest.history" = false;
        "browser.urlbar.suggest.quicksuggest.mdn" = false;
        "browser.urlbar.suggest.quicksuggest.openpage" = false;
        "browser.urlbar.suggest.quicksuggest.pocket" = false;
        "browser.urlbar.suggest.quicksuggest.recentsearches" = false;
        "browser.urlbar.suggest.quicksuggest.remotetab" = false;
        "browser.urlbar.suggest.quicksuggest.searches" = false;
        "browser.urlbar.suggest.quicksuggest.topsites" = false;
        "browser.urlbar.suggest.quicksuggest.trending" = false;
        "browser.urlbar.suggest.quicksuggest.weather" = false;
        "browser.urlbar.suggest.quicksuggest.yelp" = false;

        # Disable live search suggestions
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;

        # Disable urlbar trending search suggestions
        "browser.urlbar.trending.featureGate" = false;

        # Disable urlbar suggestions
        "browser.urlbar.addons.featureGate" = false;
        "browser.urlbar.fakespot.featureGate" = false;
        "browser.urlbar.mdn.featureGate" = false;
        "browser.urlbar.pocket.featureGate" = false;
        "browser.urlbar.weather.featureGate" = false;
        "browser.urlbar.yelp.featureGate" = false;

        # Disable urlbar clipboard suggestions
        "browser.urlbar.clipboard.featureGate" = false;

        # Disable search and form history
        # Be aware that autocomplete form data can be read by third parties
        "browser.formfill.enable" = false;

        # Enable separate default search engine in Private Windows and its UI setting
        "browser.search.separatePrivateDefault" = true;
        "browser.search.separatePrivateDefault.ui.enabled" = true;

        ## PASSWORDS
        # Disable auto-filling username & password form fields
        "signon.autofillForms" = false;

        # Disable formless login capture for Password Manager
        "signon.formlessCapture.enabled" = false;

        # Limit (or disable) HTTP authentication credentials dialogs triggered by sub-resources.
        # Hardens against potential credentials phishing
        #  - 0 = don't allow sub-resources to open HTTP authentication credentials dialogs
        #  - 1 = don't allow cross-origin sub-resources to open HTTP authentication credentials dialogs
        #  - 2 = allow sub-resources to open HTTP authentication credentials dialogs (default)
        "network.auth.subresource-http-auth-allow" = 0;

        # Disable enforcing no automatic authentication on Microsoft sites
        "network.http.windows-sso.enabled" = false;

        ## DISK AVOIDANCE
        # Disable disk cache
        "browser.cache.disk.enable" = false;

        # Disable storing extra session data
        # Define on which sites to save extra session data such as form content, cookies and POST data
        # - 0=everywhere
        # - 1=unencrypted sites
        # - 2=nowhere
        "browser.sessionstore.privacy_level" = 2;

        # Disable automatic Firefox start and session restore after reboot
        "toolkit.winRegisterApplicationRestart" = false;

        ##  TTPS (SSL/TLS / OCSP / CERTS / HPKP)
        # Require safe negotiation
        "security.ssl.require_safe_negotiation" = true;

        # Disable TLS1.3 0-RTT (round-trip time)
        # This data is not forward secret, as it is encrypted solely under keys derived using
        # the offered PSK. There are no guarantees of non-replay between connections.
        "security.tls.enable_0rtt_data" = false;

        ## CERTS / HPKP (HTTP Public Key Pinning)
        # Enable strict PKP (Public Key Pinning)
        #  - 0=disabled
        #  - 1=allow user MiTM (default; such as your antivirus)
        #  - 2=strict
        "security.cert_pinning.enforcement_level" = 2;

        # Enable CRLite
        #  - 0 = disabled
        #  - 1 = consult CRLite but only collect telemetry
        #  - 2 = consult CRLite and enforce both "Revoked" and "Not Revoked" results
        #  - 3 = consult CRLite and enforce "Not Revoked" results, but defer to OCSP for "Revoked" (default)
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.pki.crlite_mode" = 2;

        ## Mixed Content
        # Enable HTTPS-Only mode in all windows
        "dom.security.https_only_mode" = true;

        # Disable HTTP background requests
        "dom.security.https_only_mode_send_http_background_request" = false;

        ## REFERRERS
        # Control the amount of cross-origin information to send
        #  - 0=send full URI (Firefox default)
        #  - 1=scheme+host+port+path
        #  - 2=scheme+host+port
        "network.http.referer.XOriginTrimmingPolicy" = 2;

        ## CONTAINERS
        # Enable Container Tabs and its UI setting
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;

        ## PLUGINS / MEDIA / WEBRTC
        # Force WebRTC inside the proxy
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;

        # Force a single network interface for ICE candidates generation
        # When using a system-wide proxy, it uses the proxy interface
        "media.peerconnection.ice.default_address_only" = true;

        ## DOM (DOCUMENT OBJECT MODEL)
        # Prevent scripts from moving and resizing open windows
        "dom.disable_window_move_resize" = true;

        ## MISCELLANEOUS
        # Remove temp files opened from non-PB windows with an external application
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;

        # Disable UITour backend so there is no chance that a remote page can use it
        "browser.uitour.enabled" = false;
        "browser.uitour.url" = "";

        # Remove special permissions for certain mozilla domains
        "permissions.manager.defaultsUrl" = "";

        # Disable PDFJS scripting
        "pdfjs.enableScripting" = false;

        # Disable middle click on new tab button opening URLs or searches using clipboard
        "browser.tabs.searchclipboardfor.middleclick" = false;

        ## DOWNLOADS
        # Enable user interaction for security by always asking where to download
        "browser.download.useDownloadDir" = false;

        # Disable downloads panel opening on every download
        "browser.download.alwaysOpenPanel" = false;

        # Disable adding downloads to the system's "recent documents" list
        "browser.download.manager.addToRecentDocs" = false;

        # Enable user interaction for security by always asking how to handle new mimetypes
        "browser.download.always_ask_before_handling_new_types" = true;

        ## EXTENSIONS
        # Limit allowed extension directories
        #  - 1=profile
        #  - 2=user
        #  - 4=application
        #  - 8=system
        #  - 16=temporary
        #  - 31=all
        "extensions.enabledScopes" = 5; # profile & application directories

        # Disable bypassing 3rd party extension install prompts
        "extensions.postDownloadThirdPartyPrompt" = false;

        # Disable webextension restrictions on certain mozilla domains
        "extensions.webextensions.restrictedDomains" = "";

        ## ETP (ENHANCED TRACKING PROTECTION)

        # Enable ETP Strict Mode
        # ETP Strict Mode enables Total Cookie Protection (TCP)
        "browser.contentblocking.category" = "strict";
        "browser.contentblocking.report.monitor.home_page_url" = "";

        # Disable ETP web compat features
        # Includes skip lists, heuristics (SmartBlock) and automatic grants
        # Opener and redirect heuristics are granted for 30 days.
        "privacy.antitracking.enableWebcompat" = false;

        # Disable using system colors
        "browser.display.use_system_colors" = false;
        "widget.non-native-theme.use-theme-accent" = false;

        # Set all open window methods to abide by "browser.link.open_newwindow"
        "browser.link.open_newwindow.restriction" = 0;

        ## OPTIONAL OPSEC
        # Disable saving passwords
        "signon.rememberSignons" = false;

        ## Optional Hardening
        # Enforce Firefox blocklist
        "extensions.blocklist.enabled" = true;

        # Don't enforce no referer spoofing
        "network.http.referer.spoofSource" = false;

        # Enforce no First Party Isolation
        "privacy.firstparty.isolate" = false;

        # Enforce SmartBlock shims (about:compat)
        "extensions.webcompat.enable_shims" = true;

        # Enforce no TLS 1.0/1.1 downgrades
        "security.tls.version.enable-deprecated" = false;

        # Enforce disabling of Web Compatibility Reporter
        # Web Compatibility Reporter adds a "Report Site Issue" button to send data to Mozilla
        "extensions.webcompat-reporter.enabled" = false;

        # Enforce Quarantined Domains
        "extensions.quarantinedDomains.enabled" = true;

        # Enable `@-moz-document` media query
        "layout.css.moz-document.content.enabled" = true;

        "browser.eme.ui.enabled" = true;
        "media.eme.ui.enabled" = true;

        # User agent
        "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0";

        # Keybindings
        "ui.key.textcontrol.prefer_native_key_bindings_over_builtin_shortcut_key_definitions" = true;
        # https://searchcode.com/codesearch/view/26755902/
        "ui.key.accelKey" = 17; # ctrl
        "ui.key.menuAccessKey" = 18; # alt
        "ui.key.menuAccessKeyFocuses" = true;

        # Release notes and vendor URLs
        "app.releaseNotesURL" = "http://127.0.0.1/";
        "app.vendorURL" = "http://127.0.0.1/";
        "app.privacyURL" = "http://127.0.0.1/";

        # Disable plugin installer
        "plugins.hide_infobar_for_missing_plugin" = true;
        "plugins.hide_infobar_for_outdated_plugin" = true;
        "plugins.notifyMissingFlash" = false;

        # Speeding it up
        "network.http.pipelining" = true;
        "network.http.proxy.pipelining" = true;
        "network.http.pipelining.maxrequests" = 10;
        "nglayout.initialpaint.delay" = 0;
        "nglayout.initialpaint.delay_in_oopif" = 0;
        "browser.startup.preXulSkeletonUI" = false;
        "content.notify.interval" = 100000;

        # Disable session restore
        "browser.sessionstore.resume_from_crash" = false;

        # query stripping
        "privacy.query_stripping.strip_list" = "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid";

        # Extensions cannot be updated without permission
        "extensions.update.enabled" = false;

        "intl.accept_languages" = "en-US, en";

        # Allow unsigned langpacks
        "extensions.langpacks.signatures.required" = false;

        # Disable default browser checking.
        "browser.shell.checkDefaultBrowser" = false;

        # Prevent EULA dialog to popup on first run
        "browser.EULA.override" = true;

        # Don't disable extensions dropped in to a system
        # location, or those owned by the application
        "extensions.autoDisableScopes" = 3;

        # Disable dial-home features.
        "app.update.url" = "http://127.0.0.1/";
        "startup.homepage_welcome_url" = "";
        "browser.startup.homepage_override.mstone" = "ignore";

        # Help url
        "app.support.baseURL" = "http://127.0.0.1/";
        "app.support.inputURL" = "http://127.0.0.1/";
        "app.feedback.baseURL" = "http://127.0.0.1/";
        "browser.uitour.themeOrigin" = "http://127.0.0.1/";
        "plugins.update.url" = "http://127.0.0.1/";
        "browser.customizemode.tip0.learnMoreUrl" = "http://127.0.0.1/";

        # Privacy & Freedom Issues
        "browser.translation.engine" = "";
        "media.gmp-provider.enabled" = false;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;

        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.urlbar.suggest.topsites" = false;

        "browser.discovery.containers.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.discovery.sites" = "http://127.0.0.1/";
        "services.sync.prefs.sync.browser.startup.homepage" = false;
        "dom.ipc.plugins.flash.subprocess.crashreporter.enabled" = false;
        "browser.safebrowsing.downloads.remote.url" = "";
        "browser.safebrowsing.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.provider.google.updateURL" = "";
        "browser.safebrowsing.provider.google.gethashURL" = "";
        "browser.safebrowsing.provider.google4.updateURL" = "";
        "browser.safebrowsing.provider.google4.dataSharingURL" = "";
        "browser.safebrowsing.provider.google4.gethashURL" = "";
        "browser.safebrowsing.provider.mozilla.gethashURL" = "";
        "browser.safebrowsing.provider.mozilla.updateURL" = "";
        "services.sync.privacyURL" = "http://127.0.0.1/";
        "social.enabled" = false;
        "social.remote-install.enabled" = false;
        "datareporting.usage.uploadEnabled" = false;
        "datareporting.healthreport.about.reportUrl" = "http://127.0.0.1/";
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.documentServerURI" = "http://127.0.0.1/";
        "healthreport.uploadEnabled" = false;
        "social.toast-notifications.enabled" = false;
        "browser.slowStartup.notificationDisabled" = true;
        "network.http.sendRefererHeader" = 2;
        "browser.ml.chat.enabled" = false;

        # Disable gamepad API to prevent USB device enumeration
        "dom.gamepad.enabled" = false;

        # APS
        "privacy.partition.always_partition_third_party_non_cookie_storage" = true;
        "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = false;

        # We don't want to send the Origin header
        "network.http.originextension" = false;
        "network.user_prefetch-next" = false;
        "network.http.sendSecureXSiteReferrer" = false;
        "experiments.manifest.uri" = "";

        "plugin.state.flash" = 0;
        "browser.search.update" = false;

        # Disable sensors
        "dom.battery.enabled" = false;
        "device.sensors.enabled" = false;
        "camera.control.face_detection.enabled" = false;
        "camera.control.autofocus_moving_callback.enabled" = false;

        # No search suggestions
        "browser.urlbar.userMadeSearchSuggestionsChoice" = true;

        # Always ask before restoring the browsing session
        "browser.sessionstore.max_resumed_crashes" = 0;

        # Don't ping Mozilla for MitM detection, see <https://bugs.torproject.org/32321>
        "security.certerrors.mitm.priming.enabled" = false;
        "security.certerrors.recordEventTelemetry" = false;

        # Disable shield/heartbeat
        "extensions.shield-recipe-client.enabled" = false;
        "browser.selfsupport.url" = "";

        # Don't download ads for the newtab page
        "browser.newtabpage.directory.source" = "";
        "browser.newtabpage.directory.ping" = "";
        "browser.newtabpage.introShown" = true;

        # Disable geolocation
        "geo.enabled" = false;
        "geo.wifi.uri" = "";
        "browser.search.geoip.url" = "";
        "browser.search.geoSpecificDefaults" = false;
        "browser.search.geoSpecificDefaults.url" = "";
        "browser.search.modernConfig" = false;

        # Canvas fingerprint protection
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme,-CanvasExtractionBeforeUserInputIsBlocked";
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;

        # Services
        "gecko.handlerService.schemes.mailto.0.name" = "";
        "gecko.handlerService.schemes.mailto.1.name" = "";
        "gecko.handlerService.schemes.mailto.1.uriTemplate" = "";
        "gecko.handlerService.schemes.mailto.0.uriTemplate" = "";
        "browser.contentHandlers.types.0.title" = "";
        "browser.contentHandlers.types.0.uri" = "";
        "browser.contentHandlers.types.1.title" = "";
        "browser.contentHandlers.types.1.uri" = "";
        "gecko.handlerService.schemes.webcal.0.name" = "";
        "gecko.handlerService.schemes.webcal.0.uriTemplate" = "";
        "gecko.handlerService.schemes.irc.0.name" = "";
        "gecko.handlerService.schemes.irc.0.uriTemplate" = "";

        "font.default.x-western" = "sans-serif";

        "extensions.getAddons.langpacks.url" = "http://127.0.0.1/";
        "lightweightThemes.getMoreURL" = "http://127.0.0.1/";
        "browser.geolocation.warning.infoURL" = "";
        "browser.xr.warning.infoURL" = "";

        # Mobile
        "privacy.announcements.enabled" = false;
        "browser.snippets.enabled" = false;
        "browser.snippets.syncPromo.enabled" = false;
        "identity.mobilepromo.android" = "http://127.0.0.1/";
        "browser.snippets.geoUrl" = "http://127.0.0.1/";
        "browser.snippets.updateUrl" = "http://127.0.0.1/";
        "browser.snippets.statsUrl" = "http://127.0.0.1/";
        "datareporting.policy.firstRunTime" = 0;
        "datareporting.policy.dataSubmissionPolicyVersion" = 2;
        "browser.webapps.checkForUpdates" = 0;
        "browser.webapps.updateCheckUrl" = "http://127.0.0.1/";
        "app.faqURL" = "http://127.0.0.1/";

        # PFS url
        "pfs.datasource.url" = "http://127.0.0.1/";
        "pfs.filehint.url" = "http://127.0.0.1/";

        # Disable Link to FireFox Marketplace, currently loaded with non-free "apps"
        "browser.apps.URL" = "";

        # Disable Firefox Hello
        "loop.enabled" = false;

        # Use old style user_preferences, that allow javascript to be disabled
        "browser.user_preferences.inContent" = false;

        # Disable home snippets
        "browser.aboutHomeSnippets.updateUrl" = "data:text/html";

        # In <about:user_preferences>, hide "More from Mozilla"
        "browser.user_preferences.moreFromMozilla" = false;

        # Disable SSDP
        "browser.casting.enabled" = false;

        # Disable directory service
        "social.directories" = "";

        # Don't report TLS errors to Mozilla
        "security.ssl.errorReporting.enabled" = false;

        ## CRYPTO
        # General settings
        "security.tls.unrestricted_rc4_fallback" = false;
        "security.tls.insecure_fallback_hosts.use_static_list" = false;
        "security.tls.version.min" = 3;
        "security.ssl3.rsa_seed_sha" = true;

        # Avoid logjam attack
        "security.ssl3.dhe_rsa_aes_128_sha" = false;
        "security.ssl3.dhe_rsa_aes_256_sha" = false;
        "security.ssl3.dhe_dss_aes_128_sha" = false;

        # Disable Pocket integration
        "browser.pocket.enabled" = false;
        "extensions.pocket.enabled" = false;

        # Disable More from Mozilla
        "browser.preferences.moreFromMozilla" = false;

        # Enable extensions by default in private mode
        "extensions.allowPrivateBrowsingByDefault" = true;

        # Disable screenshots extension
        "extensions.screenshots.disabled" = true;

        # Disable onboarding
        "browser.onboarding.newtour" = "performance,private,addons,customize,default";
        "browser.onboarding.updatetour" = "performance,library,singlesearch,customize";
        "browser.onboarding.enabled" = false;

        # New tab settings
        "browser.newtabpage.activity-stream.showTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.disableSnippets" = true;
        "browser.newtabpage.activity-stream.tippyTop.service.endpoint" = "";
        "browser.newtabpage.activity-stream.showWeather" = false;

        # Enable xrender
        "gfx.xrender.enabled" = true;

        # Disable push notifications
        "dom.webnotifications.enabled" = false;
        "dom.push.enabled" = false;

        # Disable recommended extensions
        "browser.newtabpage.activity-stream.asrouter.useruser_prefs.cfr" = false;
        "extensions.htmlaboutaddons.discover.enabled" = false;

        # Disable the settings server
        "services.settings.server" = "";

        # Disable use of WiFi region/location information
        "browser.region.network.scan" = false;
        "browser.region.network.url" = "";
        "browser.region.update.enabled" = false;

        # Disable VPN/mobile promos
        "browser.contentblocking.report.hide_vpn_banner" = true;
        "browser.contentblocking.report.mobile-ios.url" = "";
        "browser.contentblocking.report.mobile-android.url" = "";
        "browser.contentblocking.report.show_mobile_app" = false;
        "browser.contentblocking.report.vpn.enabled" = false;
        "browser.contentblocking.report.vpn.url" = "";
        "browser.contentblocking.report.vpn-promo.url" = "";
        "browser.contentblocking.report.vpn-android.url" = "";
        "browser.contentblocking.report.vpn-ios.url" = "";
        "browser.privatebrowsing.promoEnabled" = false;

        "dom.private-attribution.submission.enabled" = false;

        # Show more ssl cert infos
        "security.identityblock.show_extended_validation" = true;

        "browser.privatebrowsing.resetPBM.enabled" = true;

        "browser.urlbar.trimURLs" = false;

        # Disable AI Chat bot
        "browser.ml.enable" = false;
        "browser.ml.modelHubRootUrl" = "http://127.0.0.1/";
      });
}
