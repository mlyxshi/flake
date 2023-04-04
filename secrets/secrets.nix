let
  main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINm0+Gbyrw0kS3xnvusayKWspsK3olPoG7PoIX/WNfb1";
in
{
  "cloudflare-dns-env.age".publicKeys = [ main ];
  "restic-env.age".publicKeys = [ main ];
  "telegram-env.age".publicKeys = [ main ];
  "rclone-env.age".publicKeys = [ main ];
  "traefik-cloudflare-env.age".publicKeys = [ main ];
  "github-private-key.age".publicKeys = [ main ];
  "shadowsocks-config.age".publicKeys = [ main ];
  "hydra-builder-sshkey.age".publicKeys = [ main ];
  "miniflux-env.age".publicKeys = [ main ];
  "transmission-env.age".publicKeys = [ main ];
  "nodestatus-env.age".publicKeys = [ main ];
  "nodestatus-database.age".publicKeys = [ main ];

  "bark-ios.age".publicKeys = [ main ];
}
