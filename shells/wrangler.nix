{ pkgs }:
pkgs.mkShell {
  packages = [ pkgs.wrangler ];
}
