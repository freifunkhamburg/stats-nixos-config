{ config, lib, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    analytics.reporting.enable = false;
    protocol = "socket";
    rootUrl = "https://stats.besaid.de/";
    auth.anonymous.enable = true;
    security = {
      adminUser = "tokudan";
      adminPasswordFile = "/var/lib/grafana/admin.pw";
      secretKeyFile = "/var/lib/grafana/security.key";
    };
    extraOptions = {
      "ANALYTICS.CHECK_FOR_UPDATES" = "false";
      "AUTH_ANONYMOUS_HIDE_VERSION" = "true";
      "AUTH_SIGNOUT_REDIRECT_URL" = "/";
    };
  };
  systemd.services.grafana.serviceConfig = {
    # upstream module already defines most hardening options
    IPAddressDeny = "any";
    IPAddressAllow = "localhost";
    MemoryDenyWriteExecute = true;
    PrivateUsers = true;
    ExecStartPost = [ 
      (pkgs.writeScript "grafana-socket-perms" ''
        #!${pkgs.stdenv.shell}
        until chmod -c 666 /run/grafana/grafana.sock ; do sleep 1; done
        '')
    ];
  };
  systemd.services.grafana-init = {
    description = "Grafana Service Daemon - initialize files";
    wantedBy = [ "grafana.service" ];
    before = [ "grafana.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      #!${pkgs.stdenv.shell}
      set -euo pipefail
      # Make sure everything but the password ends up on stderr
      exec 3>&1 >&2
      mkdir -p /var/lib/grafana
      if [ ! -s /var/lib/grafana/admin.pw ]; then
        ( tr -dc _A-Z-a-z-0-9 </dev/urandom || : ) | head -c32 > /var/lib/grafana/admin.pw
        chmod 400 /var/lib/grafana/admin.pw
        chown grafana:grafana /var/lib/grafana/admin.pw
      fi
      if [ ! -s /var/lib/grafana/security.key ]; then
        ( tr -dc _A-Z-a-z-0-9 </dev/urandom || : ) | head -c32 > /var/lib/grafana/security.key
        chmod 400 /var/lib/grafana/security.key
        chown grafana:grafana /var/lib/grafana/security.key
      fi
    '';

  };
}
