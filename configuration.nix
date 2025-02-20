# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, lib, pkgs, ... }:

{
  imports = [
    # Include the default incus configuration.
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    # Include the container-specific autogenerated configuration.
    ./incus.nix
    ./meshviewer.nix
    ./fastd-frankfurt.nix
    ./influxdb.nix
    ./grafana.nix
  ];

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-enp5s0" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking.hostName = lib.mkForce "stats";
  networking.domain = "ffffm.heroia.de";

  networking.nftables.enable = true;
  time.timeZone = "Europe/Berlin";
  networking.useNetworkd = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp4HgDDRQYOp1xXPTUkqv83dZw+DGIj5jZdBzR2u57Y tom v6"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMiPPoELDHdbSRFIDU55751WYNh97bEgBKVEgx3aEvUzAAAACnNzaDp0b20tdjg= Tom-YubiKey5NFC-2"
  ];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    iperf3
    git
    htop
    tmux
    mtr
    parted
    dmidecode
    ncdu
    bridge-utils
    tcpdump
    whois
    netcat
    jq
    tree
    tmate

    dig
    inetutils

    ethtool
    conntrack-tools

    btop

    unzip
    zip
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
