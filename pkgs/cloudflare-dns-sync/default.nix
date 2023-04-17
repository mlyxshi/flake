{ writeShellScriptBin, pkgs }:
writeShellScriptBin "cloudflare-dns-sync" ''
  source /run/sops/cloudflare-dns-env 
  exec ${pkgs.deno}/bin/deno run --allow-net --allow-env ${./main.ts} $*
''
