{ config, lib, pkgs, ... }:

let
  collector = pkgs.fetchFromGitHub {
    owner = "tokudan";
    repo = "ffhh-stats";
    rev = "76c61a0c0f7d276fd79026b551780e318901adf6";
    sha256 = "0irnc8ffm413aq3sh64sd2457yp2ax4paaf0ss9r1pkbkb8q5dgx";
  };
  collector-config = pkgs.writeText "collector-config" ''
    graph_json = https://hopglass-backend.hamburg.freifunk.net/mv1/graph.json
    nodes_json = https://hopglass-backend.hamburg.freifunk.net/mv1/nodes.json
    interval = 300
    interval_forced = true
    influx_url = http://127.0.0.1:8086/write?db=freifunk&u=knotendaten&p=@@INFLUXPASS@@&precision=s
    region = ffhh
    groups_dir = /home/freifunk/ffhh-statsgroups
    '';
in
{
  systemd.services.collector = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "influxdb.service" ];
    path = [ pkgs.wget ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 65;
      DynamicUser = true;
      PrivateTmp = true;
      RuntimeDirectory = "collector";
      ExecStart = "${pkgs.ruby.withPackages (ps: with ps; [ json ])}/bin/ruby ${collector}/query-data.influx --config /run/collector/collector-config";
      ExecStartPre = "${pkgs.writeShellScript "collector-init" ''
        until [ -s /var/lib/influxdb/knotendaten.pw ]; do
          sleep 1
        done
        read -N 32 -r knotendatenpw < /var/lib/influxdb/knotendaten.pw
        ${pkgs.gnused}/bin/sed -e "s/@@INFLUXPASS@@/$knotendatenpw/g" "${collector-config}" > /run/collector/collector-config
        '' }";
    };
  };
}
