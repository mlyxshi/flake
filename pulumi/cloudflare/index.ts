import * as cloudflare from "@pulumi/cloudflare";

const dnsv4: Record<string, string[]> = {
    "138.3.223.82": ["jp1", "top"],
    "138.2.16.45": ["jp2", "transmission-jp2", "transmission-jp2-index", "changeio", "miniflux", "rsshub", "alert", "metric"],
    "155.248.196.71": ["us","transmission-us", "transmission-us-index"],
    "185.218.6.86": ["sjc"],
    "50.114.152.206": ["alice-hk"],
    "34.150.63.217": ["gcp-hk"],
}

Object.keys(dnsv4).forEach(ip => {
    const records = dnsv4[ip];
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


const dnsv6: Record<string, string[]> = {
    "2600:1900:41a0:61b:0:0:0:0": ["gcp-hk"],
}

Object.keys(dnsv6).forEach(ip => {
    const records = dnsv6[ip];
    records.forEach(record => {
        new cloudflare.Record(record, {
            name: record,
            zoneId: "9635f891a392db45a76bca59db689db0",
            type: "AAAA",
            content: ip,
            ttl: 1,
            proxied: false,
        });
    });
})