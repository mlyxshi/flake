{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
let
  updateScript = pkgs.writeShellApplication {
    name = "update-cdn-blocklist";
    runtimeInputs = with pkgs; [
      curl
      jq
      nftables
      coreutils
      gnused
      gnugrep
    ];
    text = ''
      set -euo pipefail

      fastly=$(curl -fsSL --retry 3 --max-time 30 \
        https://api.fastly.com/public-ip-list \
        | jq -r '.addresses | join(",")')

      cloudflare=$(curl -fsSL --retry 3 --max-time 30 \
        https://www.cloudflare.com/ips-v4 \
        | grep -v '^$' | tr '\n' ',' | sed 's/,$//')

      # Refuse to apply if either fetch came back empty/garbled.
      [ -n "$fastly" ] && [ -n "$cloudflare" ] || {
        echo "empty list, aborting" >&2; exit 1;
      }

      tmp=$(mktemp)
      trap 'rm -f "$tmp"' EXIT

      cat > "$tmp" <<EOF
      flush set inet filter fastly_v4
      flush set inet filter cloudflare_v4
      add element inet filter fastly_v4 { $fastly }
      add element inet filter cloudflare_v4 { $cloudflare }
      EOF

      nft -c -f "$tmp"   # syntax-check
      nft -f "$tmp"      # atomic apply
    '';
  };
in
{

  imports = [
    self.nixosModules.services.commit-notifier
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];
  services.getty.autologinUser = "root";

  systemd.services.komari-agent.environment.AGENT_ENDPOINT = "http://138.2.16.45";
  systemd.services.komari-agent.environment.AGENT_CUSTOM_IPV4 = "35.212.172.97";

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet filter {
      set fastly_v4 {
        type ipv4_addr
        flags interval
      }
      set cloudflare_v4 {
        type ipv4_addr
        flags interval
      }
      chain output {
        type filter hook output priority filter; policy accept;
        ip daddr @fastly_v4     counter drop
        ip daddr @cloudflare_v4 counter drop
      }
    }
  '';

  systemd.services.cdn-blocklist-update = {
    description = "Refresh Fastly/Cloudflare IPv4 blocklist sets";
    after = [
      "network-online.target"
      "nftables.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "nftables.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe updateScript;
    };
  };

  systemd.timers.cdn-blocklist-update = {
    description = "Refresh CDN blocklist on boot and monthly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnCalendar = "monthly";        # = *-*-01 00:00:00
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

}
