{ config, lib, pkgs, ... }:

let
  collector = pkgs.fetchFromGitHub {
    owner = "tokudan";
    repo = "ffhh-stats";
    rev = "76c61a0c0f7d276fd79026b551780e318901adf6";
    sha256 = "0irnc8ffm413aq3sh64sd2457yp2ax4paaf0ss9r1pkbkb8q5dgx";
  };
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
      StateDirectory = "collector";
      # The config file is actually in /var/lib/private/collector, systemd maps that path to /var/lib/collector
      ExecStart = "${pkgs.ruby.withPackages (ps: with ps; [ json ])}/bin/ruby ${collector}/query-data.influx --config /var/lib/collector/ffhh.conf";
    };
  };
}
