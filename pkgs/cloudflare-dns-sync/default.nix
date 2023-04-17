{ writeShellScriptBin, pkgs }:
writeShellScriptBin "cloudflare-dns-sync" ''
  source /run/secrets/cloudflare-dns-env 
  exec ${pkgs.deno}/bin/deno run --allow-net --allow-env ${./main.ts} $*
''
