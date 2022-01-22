{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx = {
    enable = true;
    #logError = "/dev/null";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."stats" = {
      default = true;
      locations."/".proxyPass = "http://unix:${config.services.grafana.socket}:/";
    };
  };
}
