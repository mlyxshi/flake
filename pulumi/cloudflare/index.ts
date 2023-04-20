import * as pulumi from "@pulumi/pulumi";
import * as cloudflare from "@pulumi/cloudflare";

const record = new cloudflare.Record("sample-record", {
  name: "my-record",
  zoneId: "9635f891a392db45a76bca59db689db0",
  type: "A",
  value: "11.111.11.3",
  ttl: 1,
  proxied: false,
});
