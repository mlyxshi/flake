{ config, pkgs, lib, ... }: {
  systemd.services.transmission-rootfs-init = {
    after = [ "local-fs.target" "network-online.target" ];
    before = [ "transmission-build.service" ];
    wants = [ "transmission-build.service" ];
    unitConfig.ConditionPathExists = "!%S/transmission/etc/os-release";
    script = ''
      export PATH=${pkgs.wget}/bin:${pkgs.libarchive}/bin:$PATH
      wget https://github.com/mlyxshi/rootfs/raw/main/aarch64/debian.tar.zst
      bsdtar -xvf debian.tar.zst

      mkdir -p download
      cat ${./settings.json} > download/settings.json

      cat ${./rclone.sh} > download/rclone.sh 
      chmod +x download/rclone.sh

      cat ${./build.sh} > build.sh 
      chmod +x build.sh
    '';
    serviceConfig.Type = "oneshot";
    serviceConfig.StateDirectory = "transmission";
    serviceConfig.WorkingDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };


  systemd.services.transmission-build = {
    unitConfig.ConditionPathExists = "!%S/transmission/usr/local/bin/transmission-daemon";
    environment = {
      PATH = lib.mkForce "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    };
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "/bin/bash ./build.sh";
    serviceConfig.RootDirectory = "%S/transmission";
  };

  ################################################################################################################################################################################    
  age.secrets.transmission-env.file = ../../../secrets/transmission-env.age;
  age.secrets.rclone-env.file = ../../../secrets/rclone-env.age;
  age.secrets.telegram-env.file = ../../../secrets/telegram-env.age;

  systemd.services.transmission = {
    after = [ "transmission-build.service" ];
    environment = {
      TRANSMISSION_HOME = "/download";
      # Nixpkgs systemd serivce unit has default PATH, so we need to override it.(debian based rootfs)
      PATH = lib.mkForce "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    };
    serviceConfig.EnvironmentFile = [
      config.age.secrets.transmission-env.path
      config.age.secrets.telegram-env.path
      config.age.secrets.rclone-env.path
    ];
    serviceConfig.ExecStart = "/usr/local/bin/transmission-daemon --foreground --username $ADMIN --password $PASSWORD";
    serviceConfig.RootDirectory = "%S/transmission";
    wantedBy = [ "multi-user.target" ];
  };


  services.traefik = {
    dynamicConfigOptions = {
      http = {
        routers.transmission = {
          rule = "Host(`transmission.${config.networking.domain}`)";
          entryPoints = [ "web" ];
          service = "transmission";
        };

        services.transmission.loadBalancer.servers = [{
          url = "http://127.0.0.1:9091";
        }];
      };
    };
  };

  system.activationScripts.cloudflare-dns-sync-transmission = {
    deps = [ "agenix" ];
    text = "${pkgs.cloudflare-dns-sync}/bin/cloudflare-dns-sync transmission.${config.networking.domain}";
  };


  networking.nftables.enable = lib.mkForce false;
}
