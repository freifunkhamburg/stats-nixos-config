# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./boot.nix
      ./hardware-configuration.nix
      ./sshusers.nix
      ./acme.nix
      ./nginx.nix
      ./grafana.nix
      ./influxdb.nix
      ./collector.nix
    ];


  networking = {
    hostName = "stats";
    domain = "hamburg.freifunk.net";
    hostId = "7d7135dd";
    firewall.rejectPackets = true;
    firewall.logRefusedConnections = false;
    usePredictableInterfaceNames = false;
    dhcpcd.enable = false;
    nameservers = [ "213.133.99.99" "213.133.100.100" "213.133.98.98" ];
    interfaces.eth0 = {
      ipv4.addresses = [ { address = "142.132.181.225"; prefixLength = 32; } ];
      ipv6.addresses = [ { address = "2a01:4f8:1c17:dbfb::1"; prefixLength = 64; } ];
    };
    defaultGateway =  { address = "172.31.1.1"; interface = "eth0"; };
    defaultGateway6 = { address = "fe80::1"; interface = "eth0"; };
  };

  # Automatic update each day
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix = {
    autoOptimiseStore = true;
    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git htop lsof mosh nano screen socat traceroute vim wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.screen.screenrc = ''
    hardstatus alwayslastline
    hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %m-%d %{W}%c:%s %{g}]'
    defscrollback 1000
  '';

  # List services that you want to enable:

  # Support mosh connections
  programs.mosh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # User configuration for root.
  # Other users are defined in sshusers.nix
  users.extraUsers.root = {
    hashedPassword = "!!";
  };
  users.motd = with config; ''
    Welcome to ${networking.hostName}.${networking.domain}

    - This server is NixOS
    - All changes must be done through the git repository at
      /etc/nixos or https://github.com/freifunkhamburg/stats-nixos-config/
    - Other changes will be lost

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}
    '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?
}
