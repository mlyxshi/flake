#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

// See cloud-init-example/version1.yml
// By Claude Opus4.7

/* A valid IPv4 netmask is a contiguous run of 1 bits, so popcount == prefix. */
static int netmask_to_prefix(const char *mask) {
    unsigned int a, b, c, d;
    if (sscanf(mask, "%u.%u.%u.%u", &a, &b, &c, &d) != 4) return 0;
    return __builtin_popcount((a << 24) | (b << 16) | (c << 8) | d);
}

/* Extract the value between the first pair of single quotes in `line`. */
static int extract_quoted(const char *line, char *out, int outsz) {
    const char *p = strchr(line, '\'');
    if (!p) return 0;
    p++;
    const char *q = strchr(p, '\'');
    if (!q) return 0;
    int len = (int)(q - p);
    if (len >= outsz) len = outsz - 1;
    memcpy(out, p, len);
    out[len] = '\0';
    return 1;
}

/* True if `line` starts (after optional whitespace and a `-`) with `key`.
   Handles "- type:", "-  type:", "  - type:", etc. */
static int starts_with_key(const char *line, const char *key) {
    while (*line == ' ' || *line == '\t') line++;
    if (*line == '-') {
        line++;
        while (*line == ' ' || *line == '\t') line++;
    }
    return strncmp(line, key, strlen(key)) == 0;
}

/* Find block device by filesystem label using /bin/blkid.
   Writes device path into out[outsz]. Returns 1 on success, 0 on failure. */
static int blkid_by_label(const char *label, char *out, int outsz) {
    FILE *fp = popen("/bin/blkid", "r");
    if (!fp) return 0;
    char line[256], needle[64];
    snprintf(needle, sizeof needle, "LABEL=\"%s\"", label);
    int found = 0;
    while (fgets(line, sizeof line, fp)) {
        if (!strstr(line, needle)) continue;
        char *colon = strchr(line, ':');
        if (!colon) continue;
        int len = (int)(colon - line);
        if (len >= outsz) len = outsz - 1;
        memcpy(out, line, len);
        out[len] = '\0';
        found = 1;
        break;
    }
    pclose(fp);
    return found;
}

static void usage(const char *prog) {
    fprintf(stderr,
        "Usage:\n"
        "  %s <network-config.yml>   parse cloud-init network config\n"
        "  %s -L <label>             find block device by filesystem label\n",
        prog, prog);
}

int main(int argc, char *argv[]) {
    if (argc < 2) { usage(argv[0]); return 1; }

    /* -L <label> mode */
    if (strcmp(argv[1], "-L") == 0) {
        if (argc < 3) { usage(argv[0]); return 1; }
        char dev[64];
        if (!blkid_by_label(argv[2], dev, sizeof dev)) return 1;
        printf("%s\n", dev);
        return 0;
    }

    /* cloud-init YAML parse mode */
    FILE *fp = fopen(argv[1], "r");
    if (!fp) return 1;
    char line[128];
    char ip[32] = {0}, gw[32] = {0}, mask[32] = {0};
    int inside_static = 0;
    while (fgets(line, sizeof line, fp)) {
        if (starts_with_key(line, "type:")) {
            if (inside_static && ip[0]) break; /* done with static block */
            inside_static = strstr(line, "static") != NULL;
            continue;
        }
        if (!inside_static) continue;
        if      (strstr(line, "address:") && !ip[0])   extract_quoted(line, ip,   sizeof ip);
        else if (strstr(line, "netmask:") && !mask[0]) extract_quoted(line, mask, sizeof mask);
        else if (strstr(line, "gateway:") && !gw[0])   extract_quoted(line, gw,   sizeof gw);
    }
    fclose(fp);
    int prefix = netmask_to_prefix(mask);
    const char *onlink = (prefix == 32) ? "onlink" : "";
    printf("IP=%s\nGATEWAY=%s\nPREFIX=%d\nONLINK=%s\n", ip, gw, prefix, onlink);
    return 0;
}
