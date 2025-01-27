{ config, lib, pkgs, ... }:
{


  services.freifunk.meshviewer = {
    enable = true;
    domain = "map.ffffm.heroia.de";
    enableSSL = true;
    openFirewall = true;

    config = {
      #dataPath = [ "https://yanic.batman15.ffffm.net/" ];
      dataPath = [ "/data/" ];
      deprecation_enabled = true;
      deprecation_text =
        "Warnung: Dieser Knoten ist veraltet und wird seit dem 30. September 2020 nicht mehr unterstützt. Mehr Infos unter <a href='https://supportende.ffm.freifunk.net/'>supportende.ffm.freifunk.net</a>. Wenn du der Eigentümer des Gerätes bist, bitten wir dich, das Gerät dringend zu ersetzen, um weiterhin am Netz teilnehmen zu können.";
      fixedCenter = [ [ 50.5099 8.1393 ] [ 49.9282 9.3164 ] ];
      mapLayers = [{
        config = {
          attribution = ''
            <a href='https://github.com/freifunk-ffm/meshviewer/issues' target='_blank'>Report Bug</a> | Map data (c) <a href"http://openstreetmap.org">OpenStreetMap</a> contributor'';
          maxZoom = 19;
          type = "osm";
        };
        name = "OpenStreetMap";
        url = "https://tiles.darmstadt.freifunk.net/{z}/{x}/{y}.png";
      }];
      maxAge = 21;
      nodeZoom = 19;
      node_custom = "/[^.*]/ig";
      siteName = "Freifunk Frankfurt";
      nodeInfos = [
        {
          "name" = "Clientstatistik";
          "href" =  "https://grafana.ffffm.heroia.de/d/000000021/nodes?var-node={NODE_ID}&theme=light&orgId=1";
          "image" = "https://grafana.ffffm.heroia.de/render/d-solo/000000021/nodes?panelId=1&width=650&height=350&var-node={NODE_ID}&theme=light&tz=Europe%2FBerlin&orgId=1&var-hostname={NODE_NAME}";
          "title" = "Clientstatistik für {NODE_ID} - weiteren Statistiken";
          "width" = 650;
          "height" = 350;
        }
        {
          "name" = "Traffic";
          "href" =  "https://grafana.ffffm.heroia.de/d/000000021/nodes?var-node={NODE_ID}&theme=light&orgId=1";
          "image" = "https://grafana.ffffm.heroia.de/render/d-solo/000000021/nodes?panelId=2&width=650&height=350&var-node={NODE_ID}&theme=light&tz=Europe%2FBerlin&orgId=1&var-hostname={NODE_NAME}";
          "title" = "Traffic für {NODE_ID} - weiteren Statistiken";
          "width" = 650;
          "height" = 350;
        }
        {
          "name" = "Airtime";
          "href" =  "https://grafana.ffffm.heroia.de/d/000000021/nodes?var-node={NODE_ID}&theme=light&orgId=1";
          "image" = "https://grafana.ffffm.heroia.de/render/d-solo/000000021/nodes?panelId=7&width=650&height=350&var-node={NODE_ID}&theme=light&tz=Europe%2FBerlin&orgId=1&var-hostname={NODE_NAME}";
          "title" = "Airtime für {NODE_ID} - weiteren Statistiken";
          "width" = 650;
          "height" = 350;
        }
      ];
    };
  };

  services.nginx.virtualHosts."${config.services.freifunk.meshviewer.domain}" = {
    enableACME = true;
    locations."= /data".return = "301 /data/";
    locations."/data/".alias = "/var/www/html/meshviewer/data/";
  };

}
