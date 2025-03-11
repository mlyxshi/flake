import * as cloudflare from "@pulumi/cloudflare";

const dns: Record<string, string[]> = {
    "130.61.171.180": ["de", "miniflux", "rsshub", "alert", "metric"],
    "138.3.223.82": ["jp1", "top"],
    "138.2.16.45": ["jp2", "transmission-jp2", "transmission-jp2-index", "changeio"],
    "155.248.196.71": ["us", "transmission-us", "transmission-us-index"],
    "144.34.239.82": ["bwg"],
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