version=$(curl -s https://kb.nssurge.com/surge-knowledge-base/release-notes/snell  | grep -o 'snell-server-v[0-9][0-9.]*-linux-amd64\.zip' \
  | sed 's/snell-server-v//; s/-linux-amd64\.zip//' \
  | sort -V \
  | tail -n1)
  
x86_64_hash=$(nix hash convert --to sri --hash-algo sha256 $(nix-prefetch-url "https://dl.nssurge.com/snell/snell-server-v${version}-linux-amd64.zip"))


aarch64_hash=$(nix hash convert --to sri --hash-algo sha256 $(nix-prefetch-url "https://dl.nssurge.com/snell/snell-server-v${version}-linux-aarch64.zip"))


cat > /pkgs/snell/version.nix <<EOF
{
  version = "$version";
  hash = {
    x86_64-linux = "$x86_64_hash";
    aarch64-linux = "$aarch64_hash";
  };
}
EOF