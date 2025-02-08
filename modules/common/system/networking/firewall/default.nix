{
  networking.nftables = {
    enable = true;
    flushRuleset = true;

    tables = {
      # https://wiki.gbe0.com/en/linux/firewalling-and-filtering/nftables/fail2ban
      fail2ban = {
        family = "ip";
        content = ''
          chain input {
            type filter hook input priority 100;
          }
        '';
      };
    };
  };
}
