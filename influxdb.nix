{ config, pkgs, lib, ... }:
{

  services.influxdb = {
    enable = true;
  };

  services.yanic.settings.database.connection.influxdb = [
    {
      enable = true;
      database = "ffffm";
      address  = "http://127.0.0.1:8086";
      username = "";
      password = "";
    }

  ];
}
