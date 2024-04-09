import * as cloudflare from "@pulumi/cloudflare";

const dns: Record<string, string[]> = {
    "130.61.171.180": ["de"],
    "140.238.198.209": ["au", "alert", "metric"],
    "138.3.223.82": ["jp1" ],
    "138.2.16.45": ["jp2" ],
    "168.138.34.176": ["jp4", "transmission", "transmission-index", "jellyfin", "music", "changeio","baidunetdisk","baidunetdisk-index"],
    "155.248.196.71": ["us1"],
    "138.2.224.150": ["us2", "transmission-vpn-index"],
    "152.69.224.200": ["kr", "hydra", "cache"],
    "152.67.211.22": ["kr2", "hydra-x64"],
    "152.67.79.165": ["sw", "miniflux", "miniflux-silent"],
    "140.238.214.215": ["sw2", "top"],
    "152.67.78.74": ["sw3", "password"],
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