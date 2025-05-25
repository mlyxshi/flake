{ config, pkgs, lib, ... }: {
  # 创建管理员用户（密码必须设置8位以上，否则无法登陆）
  # podman container exec -it backend /bin/sh
  # python app/initial_data.py


  # copy id_ed25519 to /app/ansible/env/ssh_key

  
  virtualisation.oci-containers.containers.worker = {
    image = "docker.io/leishi1313/aurora-admin-backend:latest";
    entrypoint = "bash";
    cmd = [ "worker.sh" ];
    environment = {
      TZ = "Asia/Shanghai";
      ENABLE_SENTRY = "yes";
      DATABASE_URL = "postgresql://aurora:AuroraAdminPanel321@postgres:5432/aurora";
      ASYNC_DATABASE_URL = "postgresql+asyncpg://aurora:AuroraAdminPanel321@postgres:5432/aurora";
      TRAFFIC_INTERVAL_SECONDS = "600";
      DDNS_INTERVAL_SECONDS = "120";
    };
    volumes = [ 
      "/var/lib/aurora/app:/app/ansible/priv_data_dirs" 
      "/var/lib/aurora/ssh_key:/app/ansible/env/ssh_key"
    ];
    dependsOn = [
      "postgres"
      "redis"
    ];
  };

  virtualisation.oci-containers.containers.backend = {
    image = "docker.io/leishi1313/aurora-admin-backend:latest";
    entrypoint = "bash";
    cmd = [
      "-c"
      "while !</dev/tcp/postgres/5432; do sleep 1; done; alembic upgrade heads && python app/main.py"
    ];
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



  virtualisation.oci-containers.containers.nginx = {
    image = "docker.io/leishi1313/aurora-admin-frontend:latest";
    ports = [ "8000:80" ];
    dependsOn = [
      "backend"
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
