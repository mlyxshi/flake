import * as cloudflare from "@pulumi/cloudflare";

const dns: Record<string, string[]> = {
    "138.3.223.82": ["jp1", "top"],
    "138.2.16.45": ["jp2", "transmission-jp2", "transmission-jp2-index", "changeio", "miniflux", "rsshub", "alert", "metric"],
    "155.248.196.71": ["us","transmission-us", "transmission-us-index"],
    "140.227.176.82": ["ntt"],
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