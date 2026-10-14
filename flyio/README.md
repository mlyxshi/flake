# Fly.io free server — `de-mlyx` (Frankfurt, legacy Hobby plan)

Plain `debian:trixie-slim` machine (no Dockerfile), kept alive with `sleep infinity`.
TCP port 8888 is exposed on a dedicated IPv6 for a proxy you run inside it.

Free allowance on the legacy Hobby plan: 3 × `shared-cpu-1x` 256MB machines,
3GB persistent volume storage, 160GB outbound transfer per month.

## Setup

```sh
brew install flyctl
fly auth login

cd flyio
fly apps create de-mlyx                  # must match `app` in fly.toml
fly volumes create data --region fra --size 1 --yes
fly ips allocate-v6 -a de-mlyx                  # dedicated IPv6, free
fly deploy --ha=false                    # one machine only (default deploy creates 2)
fly ips list                             # the v6 address to put in your client
```

Then `fly ssh console`, install your proxy and have it listen on `[::]:8888` (or `0.0.0.0:8888`).
Only `/data` survives restarts/redeploys — keep binaries and config there.
Clients connect to `[<ipv6 from fly ips list>]:8888`. TCP only — Fly forwards UDP
only on a dedicated IPv4.

## Use

```sh
fly ssh console                          # shell into the machine
fly status
fly logs
fly machine list
```

## Staying free

- Keep `--ha=false` / a single machine per app, ≤ 3 machines account-wide.
- Don't run `fly ips allocate-v4` (dedicated IPv4 is $2/mo); shared IPv4 + IPv6 are free.
- Keep total volume size ≤ 3GB (`fly volumes list`).
- Outbound proxy traffic counts toward the 160GB/month.
- Check usage: `fly dashboard` → Billing.

## Tear down

```sh
fly apps destroy de-mlyx
```
