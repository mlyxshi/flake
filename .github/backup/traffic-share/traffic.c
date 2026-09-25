/* traffic — list nftables quotas with their limits and current usage.
 *
 * Parses `nft list quotas` and prints each quota name, used, limit, percent.
 *
 * Build:  cc -O2 -Wall -o traffic traffic.c
 * Usage:  traffic
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <strings.h>

static uint64_t unit_mul(const char *u) {
    if (!strcasecmp(u, "bytes") || !strcasecmp(u, "byte")) return 1ULL;
    if (!strcasecmp(u, "kbytes")) return 1024ULL;
    if (!strcasecmp(u, "mbytes")) return 1024ULL * 1024;
    if (!strcasecmp(u, "gbytes")) return 1024ULL * 1024 * 1024;
    return 0;
}

static void human(uint64_t n, char *buf, size_t len) {
    const char *u[] = {"B", "KiB", "MiB", "GiB", "TiB"};
    double v = (double)n;
    int i = 0;
    while (v >= 1024.0 && i < 4) { v /= 1024.0; i++; }
    if (i == 0)
        snprintf(buf, len, "%llu B", (unsigned long long)n);
    else
        snprintf(buf, len, "%.2f %s", v, u[i]);
}

struct row {
    char     name[80];
    uint64_t limit;
    uint64_t used;
};

int main(void) {
    FILE *fp = popen("nft list quotas 2>/dev/null", "r");
    if (!fp) {
        fprintf(stderr, "traffic: failed to run nft\n");
        return 1;
    }

    struct row rows[256];
    int nrows = 0;
    int name_w = 4;
    int in_quota = 0;          /* 1 once we've seen `quota NAME {` */
    char line[512];

    while (fgets(line, sizeof line, fp) && nrows < (int)(sizeof rows / sizeof rows[0])) {
        char name[80];

        /* `quota NAME {` opens a block */
        if (sscanf(line, " quota %79s {", name) == 1) {
            char *brace = strchr(name, '{');
            if (brace) *brace = 0;
            snprintf(rows[nrows].name, sizeof rows[nrows].name, "%s", name);
            rows[nrows].limit = 0;
            rows[nrows].used  = 0;
            in_quota = 1;
            continue;
        }

        if (!in_quota) continue;

        /* `over N UNIT used M UNIT` or `over N UNIT` */
        char lim_u[16], used_u[16];
        unsigned long long lim_n, used_n;
        int n = sscanf(line, " over %llu %15s used %llu %15s",
                       &lim_n, lim_u, &used_n, used_u);
        if (n == 4) {
            uint64_t lm = unit_mul(lim_u), um = unit_mul(used_u);
            if (lm && um) {
                rows[nrows].limit = (uint64_t)lim_n * lm;
                rows[nrows].used  = (uint64_t)used_n * um;
            }
        } else {
            n = sscanf(line, " over %llu %15s", &lim_n, lim_u);
            if (n == 2) {
                uint64_t lm = unit_mul(lim_u);
                if (lm) rows[nrows].limit = (uint64_t)lim_n * lm;
            }
        }

        /* close-brace ends the current quota block */
        if (strchr(line, '}')) {
            int wlen = (int)strlen(rows[nrows].name);
            if (wlen > name_w) name_w = wlen;
            nrows++;
            in_quota = 0;
        }
    }

    int rc = pclose(fp);
    if (rc != 0) {
        fprintf(stderr, "traffic: nft exited with status %d "
                        "(insufficient privileges?)\n", rc);
        return 1;
    }

    if (nrows == 0) {
        fprintf(stderr, "traffic: no quotas found\n");
        return 1;
    }

    for (int i = 0; i < nrows; i++) {
        char us[32], ls[32];
        human(rows[i].used,  us, sizeof us);
        human(rows[i].limit, ls, sizeof ls);
        double pct = rows[i].limit
            ? 100.0 * (double)rows[i].used / (double)rows[i].limit
            : 0.0;
        printf("%-*s  %12s / %-12s  %6.2f%%\n",
               name_w, rows[i].name, us, ls, pct);
    }
    return 0;
}
