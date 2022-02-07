{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    virtualHosts."statistik.hamburg.freifunk.net" = {
      enableACME = true;
      forceSSL = true;
      extraConfig = ''
        rewrite ^/(.*)$ https://stats.hamburg.freifunk.net/ redirect;
        '';
    };
    virtualHosts."stats.hamburg.freifunk.net" = {
      default = true;
      enableACME = true;
      forceSSL = true;
      extraConfig = ''
        access_log off;
        '';
      locations."/".proxyPass = "http://unix:${config.services.grafana.socket}:/";
    };
  };
}
