{ writeShellScriptBin, pkgs }:
writeShellScriptBin "cloudflare-dns-sync" ''
  source /run/agenix/cloudflare-dns-env 
  exec ${pkgs.deno}/bin/deno run --allow-net --allow-env ${./main.ts} $*
''
