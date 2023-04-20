import * as pulumi from "@pulumi/pulumi";
import * as cloudflare from "@pulumi/cloudflare";

const zoneId = "9635f891a392db45a76bca59db689db0";

new cloudflare.Record("sample-record", {
  name: "alert",
  zoneId: zoneId,
  type: "A",
  value: "140.238.198.209",
  ttl: 1,
  proxied: false,
});
