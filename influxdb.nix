{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.influxdb ];
  services.influxdb = {
    enable = true;
    dataDir = "/var/lib/influxdb";
    extraConfig = {
      meta.reporting-disabled = true;
      data.query-log-enabled = false;
      http.bind-address = "localhost:8086";
      http.auth-enabled = true;
      http.log-enabled = false;
    };
  };
  systemd.services.influxdb = {
    before = [ "grafana.service" ];
    serviceConfig = {
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      ReadWritePaths = "/var/lib/influxdb";
      RestrictAddressFamilies = [ "~AF_PACKET" "~AF_NETLINK" "~AF_UNIX" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [ "~@clock" "~@cpu-emulation" "~@debug" "~@module" "~@mount" "~@obsolete" "~@privileged" "~@raw-io" "~@reboot" "~@resources" "~@swap" ];
      CapabilityBoundingSet = "";
      IPAddressDeny = "any";
      IPAddressAllow = "localhost";
      UMask = "077";
      RuntimeDirectory = "influxdb";
      ExecStartPre = [ (pkgs.writeShellScript "influxdb-first-run" ''
        [ -d /var/lib/influxdb/meta ] || touch /var/lib/influxdb/need-init
        '') ];
      ExecStartPost = lib.mkForce [ (pkgs.writeShellScript "influxdb-first-run" ''
        set -euo pipefail
        if [ ! -s /var/lib/influxdb/admin.pw ]; then
          ( tr -dc _A-Z-a-z-0-9 </dev/urandom || : ) | head -c32 > /var/lib/influxdb/admin.pw
          chmod 400 /var/lib/influxdb/admin.pw
        fi
        if [ ! -s /var/lib/influxdb/knotendaten.pw ]; then
          ( tr -dc _A-Z-a-z-0-9 </dev/urandom || : ) | head -c32 > /var/lib/influxdb/knotendaten.pw
          chmod 400 /var/lib/influxdb/knotendaten.pw
        fi
        if [ ! -s /var/lib/influxdb/grafana.pw ]; then
          ( tr -dc _A-Z-a-z-0-9 </dev/urandom || : ) | head -c32 > /var/lib/influxdb/grafana.pw
          chmod 400 /var/lib/influxdb/grafana.pw
        fi
        until ${pkgs.curl}/bin/curl --connect-timeout 1 http://127.0.0.1:8086/ping; do
          sleep 1
        done
        if [ -e /var/lib/influxdb/need-init ]; then
          rm -f /var/lib/influxdb/need-init
          read -N 32 -r adminpw < /var/lib/influxdb/admin.pw
          read -N 32 -r knotendatenpw < /var/lib/influxdb/knotendaten.pw
          read -N 32 -r grafanapw < /var/lib/influxdb/grafana.pw
          ${config.services.influxdb.package}/bin/influx -execute "create user admin with password '$adminpw' WITH ALL PRIVILEGES"
          ${config.services.influxdb.package}/bin/influx -username admin -password "$adminpw" -execute 'create database freifunk'
          ${config.services.influxdb.package}/bin/influx -username admin -password "$adminpw" -database freifunk -execute "grant all on freifunk to admin"
          ${config.services.influxdb.package}/bin/influx -username admin -password "$adminpw" -database freifunk -execute "create user grafana with password '$grafanapw'"
          ${config.services.influxdb.package}/bin/influx -username admin -password "$adminpw" -database freifunk -execute "create user knotendaten with password '$knotendatenpw'"
          ${config.services.influxdb.package}/bin/influx -username admin -password "$adminpw" -database freifunk -execute "grant read on freifunk to grafana"
          ${config.services.influxdb.package}/bin/influx -username admin -password "$adminpw" -database freifunk -execute "grant write on freifunk to knotendaten"
        fi
        '') ];
    };
  };
}
