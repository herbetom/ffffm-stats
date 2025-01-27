{ config, lib, pkgs, ... }:
{
  security.acme = {
    defaults = {
      email = "certificates@ffffm.heroia.de";
    };
    acceptTerms = true;
  };
}
