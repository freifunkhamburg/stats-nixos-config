{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    #logError = "/dev/null";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."stats.hamburg.freifunk.net" = {
      default = true;
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://unix:${config.services.grafana.socket}:/";
    };
  };
}
