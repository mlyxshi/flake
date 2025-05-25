{ config, pkgs, lib, ... }: {

  # virtualisation.oci-containers.containers.changedetection = {
  #   image = "ghcr.io/dgtlmoon/changedetection.io";
  #   volumes = [ "/var/lib/changedetection:/datastore" ];
  #   environment = { PLAYWRIGHT_DRIVER_URL = "ws://chrome-headless:3000"; };
  #   dependsOn = [ "chrome-headless" ];
  #   extraOptions = lib.concatMap (x: [ "--label" x ]) [
  #     "io.containers.autoupdate=registry"
  #     "traefik.enable=true"
  #     "traefik.http.routers.changedetection.rule=Host(`changeio.${config.networking.domain}`)"
  #     "traefik.http.routers.changedetection.entrypoints=websecure"
  #   ];
  # };

  virtualisation.oci-containers.containers.aurora-worker = {
    image = "docker.io/leishi1313/aurora-admin-backend:latest";
    entrypoint = "bash worker.sh";
    environment = {
      TZ = "Asia/Shanghai";
      ENABLE_SENTRY = "yes";
      DATABASE_URL = "postgresql://aurora:AuroraAdminPanel321@postgres:5432/aurora";
      ASYNC_DATABASE_URL = "postgresql+asyncpg://aurora:AuroraAdminPanel321@postgres:5432/aurora";
      TRAFFIC_INTERVAL_SECONDS = "600";
      DDNS_INTERVAL_SECONDS = "120";
    };
    volumes = [ "/var/lib/aurora/app:/app/ansible/priv_data_dirs" ];
    dependsOn = [
      "postgres"
      "redis"
    ];
  };

  virtualisation.oci-containers.containers.aurora-backend = {
    image = "docker.io/leishi1313/aurora-admin-backend:latest";
    entrypoint = ''
      bash -c "while !</dev/tcp/postgres/5432; do sleep 1; done; alembic upgrade heads && python app/main.py"
    '';
    environment = {
      TZ = "Asia/Shanghai";
      PYTHONPATH = ".";
      DATABASE_URL = "postgresql://aurora:AuroraAdminPanel321@postgres:5432/aurora";
      ASYNC_DATABASE_URL = "postgresql+asyncpg://aurora:AuroraAdminPanel321@postgres:5432/aurora";
      SECREY_KEY = "AuroraAdminPanel321";
    };
    volumes = [ "/var/lib/aurora/app:/app/ansible/priv_data_dirs" ];
    dependsOn = [
      "postgres"
      "redis"
    ];
  };



  virtualisation.oci-containers.containers.aurora-front = {
    image = "docker.io/leishi1313/aurora-admin-frontend:latest";
    ports = [ "8000:80" ];
    dependsOn = [
      "aurora-backend"
    ];
  };

  virtualisation.oci-containers.containers.postgres = {
    image = "docker.io/library/postgres:13-alpine";
    environment = {
      POSTGRES_USER = "aurora";
      POSTGRES_PASSWORD = "AuroraAdminPanel321";
      POSTGRES_DB = "aurora";
    };
    volumes = [ "/var/lib/aurora/postgresql:/var/lib/postgresql/data" ];
  };

  virtualisation.oci-containers.containers.redis = {
    image = "docker.io/library/redis:8-alpine";
  };

}
