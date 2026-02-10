{
  config,
  ...
}:
{

  services.telegraf = {
    enable = true;
    extraConfig = {
      inputs = {
        cpu = { };
        disk = {
          ignore_fs = [
            "tmpfs"
            "devtmpfs"
            "devfs"
            "overlay"
            "aufs"
            "squashfs"
            "vfat"
          ];
        };
        diskio = { };
        mem = { };
        net = { };
        processes = { };
        system = { };
        systemd_units = { };
      };
      outputs = {
        prometheus_client = {
          listen = "127.0.0.0:9273";
          metric_version = 2;
          path = "/metrics";
        };
      };
    };
  };

  services.traefik.dynamic.files."telegraf".settings = {
    http = {
      routers.telegraf = {
        rule = "Host(`${config.networking.fqdn}`) && Path(`/metrics`)";
        entryPoints = [ "web" ];
        service = "telegraf";
      };

      services.telegraf.loadBalancer.servers = [
        {
          url = "http://${config.services.telegraf.extraConfig.outputs.prometheus_client.listen}";
        }
      ];
    };
  };
}
