{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  ...
}:
let
  trafficBot = pkgs.writeText "traffic-bot.py" ''
    import json, subprocess, urllib.request, urllib.parse, time

    TOKEN = open("/secret/bot").read().strip()
    API = "https://api.telegram.org/bot" + TOKEN

    def human(n):
        n = float(n)
        for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
            if n < 1024 or unit == "TiB":
                return ("%d B" % n) if unit == "B" else ("%.2f %s" % (n, unit))
            n /= 1024

    def counters():
        out = subprocess.run(
            ["nft", "-j", "list", "counters", "table", "inet", "FIREWALL"],
            capture_output=True, text=True, check=True).stdout
        res = {}
        for item in json.loads(out)["nftables"]:
            c = item.get("counter")
            if c and "name" in c:
                res[c["name"]] = c.get("bytes", 0)
        return res

    def reply_text():
        c = counters()
        tu = c.get("tcp8888_out", 0); td = c.get("tcp8888_in", 0)
        uu = c.get("udp8888_out", 0); ud = c.get("udp8888_in", 0)
        total = tu + td + uu + ud
        return ("tcp up:   %s\n"
                "tcp down: %s\n"
                "udp up:   %s\n"
                "udp down: %s\n"
                "total:    %s") % (human(tu), human(td), human(uu),
                                   human(ud), human(total))

    def send(chat_id, text):
        data = urllib.parse.urlencode({"chat_id": chat_id, "text": text}).encode()
        urllib.request.urlopen(API + "/sendMessage", data=data)

    def main():
        offset = 0
        while True:
            try:
                url = "%s/getUpdates?timeout=30&offset=%d" % (API, offset)
                resp = json.load(urllib.request.urlopen(url, timeout=40))
                for upd in resp.get("result", []):
                    offset = upd["update_id"] + 1
                    msg = upd.get("message") or {}
                    text = (msg.get("text") or "").strip()
                    if text.split("@")[0] == "/traffic":
                        send(msg["chat"]["id"], reply_text())
            except Exception:
                time.sleep(5)

    if __name__ == "__main__":
        main()
  '';
in
{

  imports = [
    self.nixosModules.programs.vscode-ssh-remote
  ];

  services.openssh.ports = [ 23333 ];

  boot.blacklistedKernelModules = [ "virtio_balloon" ];

  services.caddy.enable = true;
  services.caddy.virtualHosts.":8010".extraConfig = ''
    root * /var/lib/transmission/files
    file_server browse
  '';

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    table inet FIREWALL {
      counter tcp8888_in  { }
      counter tcp8888_out { }
      counter udp8888_in  { }
      counter udp8888_out { }

      chain INPUT {
        type filter hook input priority 0; policy drop;
        iifname lo accept
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        meta nfproto ipv4 tcp dport 8888 counter name "tcp8888_in"
        meta nfproto ipv4 udp dport 8888 counter name "udp8888_in"
        ct state {established, related} accept
        tcp dport { 23333, 8888, 8889, 5201, 8010, 9999 } accept
        udp dport { 5201, 8888, 9999 } accept
      }

      chain OUTPUT {
        type filter hook output priority 0; policy accept;
        meta nfproto ipv4 tcp sport 8888 counter name "tcp8888_out"
        meta nfproto ipv4 udp sport 8888 counter name "udp8888_out"
      }
    }
  '';

  systemd.services.snell2 = {
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${lib.getExe pkgs.snell} -c /secret/snell2";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.komari-agent.environment.AGENT_MONTH_ROTATE = "24";

  systemd.services.traffic-bot = {
    after = [ "network.target" "nftables.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.nftables ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${trafficBot}";
    };
  };
}
