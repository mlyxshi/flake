import * as cloudflare from "@pulumi/cloudflare";

const dns: Record<string, string[]> = {
    "138.3.223.82": ["jp1", "top"],
    "138.2.16.45": ["jp2", "transmission-jp2", "transmission-jp2-index", "changeio", "miniflux", "rsshub", "alert", "metric"],
    "155.248.196.71": ["us","transmission-us", "transmission-us-index"],
    "210.216.173.19": ["kr"],
    "50.114.152.206": ["alice-hk"],
    "34.150.94.176": ["gcp-hk"],
}

Object.keys(dns).forEach(ip => {
    const records = dns[ip];
    records.forEach(record => {
        new cloudflare.Record(record, {
            name: record,
            zoneId: "9635f891a392db45a76bca59db689db0",
            type: "A",
            content: ip,
            ttl: 1,
            proxied: false,
        });
    });
})