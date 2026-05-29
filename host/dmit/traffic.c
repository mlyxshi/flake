/* traffic — print the inet TRAFFIC nftables counters for a given port.
 *
 * Reads `nft list counters table inet TRAFFIC`, sums the tcp/udp in/out
 * byte counts for counters named tcp<PORT>_in / _out / udp<PORT>_in / _out,
 * and prints a human-readable breakdown plus total.
 *
 * Build:  cc -O2 -Wall -o traffic traffic.c
 * Usage:  traffic PORT          # human-readable
 *         traffic PORT -b       # raw total bytes only (for scripts)
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

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
    const char *port = NULL;
    int bytes_only = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-b") == 0) bytes_only = 1;
        else if (!port) port = argv[i];
    }
    if (!port) {
        fprintf(stderr, "usage: %s PORT [-b]\n", argv[0]);
        return 2;
    }

    /* counter names we care about, derived from the port */
    char names[N][80];
    snprintf(names[0], sizeof names[0], "tcp_%s_in", port);
    snprintf(names[1], sizeof names[1], "tcp_%s_out", port);
    snprintf(names[2], sizeof names[2], "udp_%s_in", port);
    snprintf(names[3], sizeof names[3], "udp_%s_out", port);

    FILE *fp = popen("nft list counters table inet TRAFFIC 2>/dev/null", "r");
    if (!fp) {
        fprintf(stderr, "traffic: failed to run nft\n");
        return 1;
    }

    uint64_t b[N] = {0};
    char line[512];
    char cur[80] = {0};            /* name of counter block we're inside */

    while (fgets(line, sizeof line, fp)) {
        char name[80];
        unsigned long long pkts, byts;
        /* "counter NAME {"  — opens a block */
        if (sscanf(line, " counter %79s {", name) == 1) {
            snprintf(cur, sizeof cur, "%s", name);
            continue;
        }
        /* "packets N bytes M" — the body line */
        if (cur[0] &&
            sscanf(line, " packets %llu bytes %llu", &pkts, &byts) == 2) {
            for (int i = 0; i < N; i++)
                if (strcmp(cur, names[i]) == 0) b[i] = byts;
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
