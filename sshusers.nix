{ lib, pkgs, ... }:

# Setup users. To add a new user:
# 1. Add the name of the user to the list in the second-to-last line
# 2. Make sure that the git repo contains the key as "$USER.pub"
# 3. Make sure that the commit ("rev") contains the latest commit hash. If it correct, jump to step 7.
# 4. If you changed the commit, manipulate the sha512 entry by changing the first character from 0 to 1 or 1 to 0.
# 5. Run "nixos-rebuild build"
# 6. Wait for a message about an invalid hash and replace the hash in this file with the new one.
# 7. Run "nixos-rebuild switch"
# 8. Let the user login and change their password

let
  sshkeys = pkgs.fetchFromGitHub {
    owner = "freifunkhamburg";
    repo = "ssh-keys";
    rev = "286c324f0c0c9ddfd37eee286d064b36dc5e4c2c";
    sha512 = "034d5y75wr8vyz3r222hxar1wm0vmqryvgcji2lh1f8jxpgs3nchb0w2qv44msz085s9p4i92s96z9cb8zapmwj3anm0p8f156pf34c";
  };
  getpubkeys = user: builtins.readFile "${sshkeys}/${user}.pub";
  mkuser = user: { name = user; isNormalUser = true; extraGroups = [ "wheel" ]; initialPassword = "test1234"; openssh.authorizedKeys.keys = [ (getpubkeys user) ]; };
in
{
  services.openssh = {
    enable = true;
    # Only allow login through pubkey
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  users.users = lib.genAttrs [ "tokudan" ] mkuser ;
}
