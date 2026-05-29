/* traffic — print the inet TRAFFIC nftables counters for port 8888.
 *
 * Reads `nft list counters table inet TRAFFIC`, sums tcp/udp in/out
 * byte counts, and prints a human-readable breakdown plus total.
 *
 * Build:  cc -O2 -Wall -o traffic traffic.c
 * Usage:  traffic            # human-readable
 *         traffic -b         # raw total bytes only (for scripts)
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static const char *NAMES[] = {
    "tcp8888_in", "tcp8888_out", "udp8888_in", "udp8888_out",
};
enum { N = 4 };

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

int main(int argc, char **argv) {
    int bytes_only = (argc > 1 && strcmp(argv[1], "-b") == 0);

    FILE *fp = popen("nft list counters table inet TRAFFIC 2>/dev/null", "r");
    if (!fp) {
        fprintf(stderr, "traffic: failed to run nft\n");
        return 1;
    }

    uint64_t b[N] = {0};
    char line[512];
    char cur[64] = {0};            /* name of counter block we're inside */

    while (fgets(line, sizeof line, fp)) {
        char name[64];
        unsigned long long pkts, byts;
        /* "counter NAME {"  — opens a block */
        if (sscanf(line, " counter %63s {", name) == 1) {
            snprintf(cur, sizeof cur, "%s", name);
            continue;
        }
        /* "packets N bytes M" — the body line */
        if (cur[0] &&
            sscanf(line, " packets %llu bytes %llu", &pkts, &byts) == 2) {
            for (int i = 0; i < N; i++)
                if (strcmp(cur, NAMES[i]) == 0) b[i] = byts;
            cur[0] = 0;
        }
    }

    int rc = pclose(fp);
    if (rc != 0) {
        fprintf(stderr, "traffic: nft exited with status %d "
                        "(table missing or insufficient privileges?)\n", rc);
        return 1;
    }

    uint64_t td = b[0], tu = b[1], ud = b[2], uu = b[3];
    uint64_t total = td + tu + ud + uu;

    if (bytes_only) {
        printf("%llu\n", (unsigned long long)total);
        return 0;
    }

    char s[5][32];
    human(tu, s[0], sizeof s[0]);
    human(td, s[1], sizeof s[1]);
    human(uu, s[2], sizeof s[2]);
    human(ud, s[3], sizeof s[3]);
    human(total, s[4], sizeof s[4]);

    printf("tcp up:   %s\n"
           "tcp down: %s\n"
           "udp up:   %s\n"
           "udp down: %s\n"
           "total:    %s\n",
           s[0], s[1], s[2], s[3], s[4]);
    return 0;
}
