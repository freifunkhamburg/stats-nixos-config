{ ... }:

{
  security.acme.acceptTerms = true;
  security.acme.email = "kontakt@hamburg.freifunk.net";
  users.groups.certs = {
    members = [ "nginx" ];
  };
}
