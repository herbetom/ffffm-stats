{ config, lib, pkgs, ... }:

let
  sources = import ./npins;

  generateConnection = { domain, port }: {
    services.fastd."ffffm-${domain}" = {
      secretKeyIncludeFile = "${pkgs.writeText "fastd-secret.key" ''
        secret "08e003f5b8a32c0620b073112363b07661d34646112208c9fe2233161dd4ed5c";
      ''}";
      extraConfig = ''
        interface "vpnfm-${domain}";
      '';
      peers = [
        {
          name = "gw01";
          remote = [
            { address = "gw01.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "e0852870545125d8b0688815a25397f69b5e675991b25caeb18770745de67805";
        }
        {
          name = "gw02";
          remote = [
            { address = "gw02.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "ce38642d5812798bf6e735f2fb757e32f1797092770f7aa310bf5691572c0748";
        }
        {
          name = "gw03";
          remote = [
            { address = "gw03.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "ab4f16ba4860da6239dca1f1b7e54cdc89602146d4fc7471de7ffbc6f233e2f7";
        }
        {
          name = "gw04";
          remote = [
            { address = "gw04.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "af8797890b61446fa8d1d69d9f92628632ddf5a6dcd2f39564dc8670eb7ac6be";
        }
        {
          name = "gw05";
          remote = [
            { address = "gw05.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "d95503e4e8980b8154ea38ddc84b25c90fae198c13577b31c7813d9aac6269fd";
        }
        {
          name = "gw06";
          remote = [
            { address = "gw06.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "f098b594422d71a188e68fd6ac909ec152c9c0f3dac1cd218145c89e236028f6";
        }
        {
          name = "gw07";
          remote = [
            { address = "gw07.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "4ea222b6e9d0ce7d69f0ab240cc985d5d53d6a397409bdc8bc727430f8847cc9";
        }
        {
          name = "gw08";
          remote = [
            { address = "gw08.batman15.ffffm.net"; port = port; }
          ];
          pubkey = "035f2a9127df6fdaa2c8f65eb85b37229f931c4393d75e0590cc4b3583df6633";
        }
      ];
    };

    systemd.network = {
      netdevs = {
        "70-bat-${domain}" = {
          netdevConfig = {
            Kind = "batadv";
            Name = "bat-${domain}";
          };
          batmanAdvancedConfig = {
            GatewayMode = "client";
            OriginatorIntervalSec = "5";
            RoutingAlgorithm = "batman-iv";
            HopPenalty = 10;
          };
        };
      };
      networks = {
        "50-vpn-${domain}" = {
          matchConfig = {
            Name = "vpnfm-${domain}";
          };
          linkConfig = {
            RequiredForOnline = false;
          };
          networkConfig = {
            IPv6AcceptRA = false;
            KeepConfiguration = true;
            LinkLocalAddressing = "no";
            BatmanAdvanced = "bat-${domain}";
          };
          DHCP = "no";
          extraConfig = ''
          '';
        };
        "70-bat-${domain}" = {
          matchConfig = {
            Name = "bat-${domain}";
          };
          linkConfig = {
            RequiredForOnline = false;
          };
          networkConfig = {
            IPv6AcceptRA = true;
          };
          DHCP = "no";
          dhcpV4Config = {
            UseDNS = false;
            UseGateway = false;
            UseRoutes = false;
            UseDomains = false;
          };
          ipv6AcceptRAConfig = {
            UseDNS = false;
            UseGateway = false;
            UseDomains = false;
          };
        };
      };
    };
    networking.firewall.extraInputRules = ''
      iifname "bat-${domain}" udp dport 10001 counter accept comment "accept yanic ${domain}"
    '';
    services.yanic.settings.respondd.interfaces = [
      {
        ifname = "bat-${domain}";
        multicast_address = "ff05::2:1001";
        port = 10001;
      }
    ];
  };

  fastdConnections = [
    (generateConnection { domain = "dom0"; port = 10000; })
    (generateConnection { domain = "dom1"; port = 10010; })
    (generateConnection { domain = "dom2"; port = 10020; })
    (generateConnection { domain = "dom3"; port = 10030; })
    (generateConnection { domain = "dom4"; port = 10040; })
    (generateConnection { domain = "dom5"; port = 10050; })
    (generateConnection { domain = "dom6"; port = 10060; })
    (generateConnection { domain = "dom7"; port = 10070; })
    (generateConnection { domain = "dom8"; port = 10080; })
    (generateConnection { domain = "dom9"; port = 10090; })
    (generateConnection { domain = "dom10"; port = 10100; })
    (generateConnection { domain = "dom11"; port = 10110; })
    (generateConnection { domain = "dom12"; port = 10120; })
    (generateConnection { domain = "dom13"; port = 10130; })
    (generateConnection { domain = "dom14"; port = 10140; })
    (generateConnection { domain = "dom15"; port = 10150; })
    (generateConnection { domain = "dom16"; port = 10160; })
    (generateConnection { domain = "dom17"; port = 10170; })
  ];

in
{
  imports = [
    (import sources.nix-freifunk)
  ];

  config = lib.mkMerge ( fastdConnections ++[
    {
      services.yanic = {
      enable  = true;
      autostart = true;
      settings = {
        respondd = {
          enable = true;
          synchronize = "1m";
          collect_interval = "1m";
          # sites = {
          #   "${cfg.yanic.defaultSite}" = {
          #     domains = builtins.concatMap (attrSet: builtins.attrNames attrSet) (lib.mapAttrsToList (name: value: value.names) enabledDomains);
          #   };
          # };
        };
        webserver = {
          enable = false;
          bind = "127.0.0.1:8080";
        };
        nodes = {
          state_path = "/var/lib/yanic/state.json";
          prune_after = "7d";
          save_interval = "5s";
          offline_after = "10m";
          output = {
            meshviewer-ffrgb = [
              {
                enable = true;
                path = "/var/www/html/meshviewer/data/meshviewer.json";
                filter = {
                  no_owner = true;
                };
              }
            ];
          };
        };
        database = {
          delete_after = "7d";
          delete_interval = "1h";
        };
      };
    };

    systemd.services.yanic.preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p /var/www/html/meshviewer/data/
      ${pkgs.coreutils}/bin/mkdir -p /var/lib/yanic/
    '';
    }
  ]);
}

# https://chaos.expert/FFFFM/site/-/blob/stable/domains/dom3.conf?ref_type=heads

# yanic query "bat-dom0" "ff05::2:1001" --wait 30 --port 10001 --loglevel 0
