import * as pulumi from "@pulumi/pulumi";
import * as cloudflare from "@pulumi/cloudflare";

const zoneId = "9635f891a392db45a76bca59db689db0";

const dns: Record<string, string[]> = {
    "130.61.171.180": ["de", "transmission", "transmission-index"],
    "140.238.198.209": ["au", "alert"],
}

Object.keys(dns).forEach(ip => {
    const records = dns[ip];
    records.forEach(record => {
        new cloudflare.Record(record, {
            name: record,
            zoneId: zoneId,
            type: "A",
            value: ip,
            ttl: 1,
            proxied: false,
        });
    });
});