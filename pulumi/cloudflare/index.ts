import * as cloudflare from "@pulumi/cloudflare";

const dns: Record<string, string[]> = {
    "130.61.171.180": ["de", "password", "miniflux", "miniflux-silent", "rsshub", "alert", "metric", "top"],
    "138.3.223.82": ["jp1", "auto-bangumi","qbittorrent", "jellyfin"],
    "138.2.16.45": ["jp2", "transmission", "transmission-index","music", "changeio", "baidunetdisk", "baidunetdisk-index"],
    "168.138.195.121": ["jp3"],
    "155.248.196.71": ["us1", "transmission-vpn-index"],
}

Object.keys(dns).forEach(ip => {
    const records = dns[ip];
    records.forEach(record => {
        new cloudflare.Record(record, {
            name: record,
            zoneId: "9635f891a392db45a76bca59db689db0",
            type: "A",
            value: ip,
            ttl: 1,
            proxied: false,
        });
    });
})