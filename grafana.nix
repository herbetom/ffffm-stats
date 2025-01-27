{ config, pkgs, lib, ... }:
{
  imports = [
    ./acme.nix
  ];

  services.grafana = {
    enable = true;
    settings = {
      "auth.anonymous" = {
        enabled = true;
        org_name = "Main Org.";
      };
      server = {
        protocol = "socket";
        root_url = "https://grafana.ffffm.heroia.de";
      };
      rendering.callback_url = "https://grafana.ffffm.heroia.de";
      rendering.server_url = "http://localhost:${builtins.toString config.services.grafana-image-renderer.settings.service.port}/render";
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "influxdb.${builtins.toString config.networking.domain}";
          url = "http://localhost:8086";
          type = "influxdb";
          editable = false;
          jsonData.dbName = "ffffm";
        }
      ];
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
      marcusolsson-dynamictext-panel
    ];
  };

  services.grafana-image-renderer = {
    enable = true;
    settings = {
      service.metrics = {
        enabled = true;
        collectDefaultMetrics = true;
        requestDurationBuckets = [1 5 7 9 11 13 15 20 30];
      };
      rendering = {
        timingMetrics = true;
      };
    };
  };

  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ "grafana" ];

  services.nginx.virtualHosts."grafana.ffffm.heroia.de" = {
    locations."/" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      recommendedProxySettings = true;
    };
    locations."/render/" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      extraConfig = ''
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        add_header X-FFRN-LOCAL-Cache-Status $upstream_cache_status;
        proxy_cache rendercache;
        proxy_cache_valid 300s;
        proxy_cache_lock on;
        proxy_cache_lock_age 60s;
        proxy_cache_lock_timeout 60s;
        proxy_ignore_headers Cache-Control Expires;
        proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_503 http_504;
      '';
    };
    locations."=/metrics" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      extraConfig = ''
        allow 127.0.0.0/8;
        allow ::1;
        deny  all;
      '';
    };
    forceSSL = true;
    enableACME = true;
  };

  services.nginx.proxyCachePath."rendercache" = {
    enable = true;
    maxSize = "1024M";
    levels = "1:2";
    keysZoneSize = "10m";
    keysZoneName = "rendercache";
    inactive = "10m";
  };
}
