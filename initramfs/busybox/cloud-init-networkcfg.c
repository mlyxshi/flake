#include <stdio.h>
#include <string.h>

// See cloud-init-example/version1.yml
// By Claude Sonnet4.6

static int netmask_to_prefix(const char *mask) {
    unsigned int a = 0, b = 0, c = 0, d = 0;
    const char *p = mask;
    
    while(*p >= '0' && *p <= '9') a = a * 10 + (*p++ - '0'); if(*p == '.') p++;
    while(*p >= '0' && *p <= '9') b = b * 10 + (*p++ - '0'); if(*p == '.') p++;
    while(*p >= '0' && *p <= '9') c = c * 10 + (*p++ - '0'); if(*p == '.') p++;
    while(*p >= '0' && *p <= '9') d = d * 10 + (*p++ - '0');

    unsigned int bits = (a << 24) | (b << 16) | (c << 8) | d;
    int prefix = 0;
    while (bits & 0x80000000u) { prefix++; bits <<= 1; }
    return prefix;
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

int main(int argc, char *argv[]) {
    if (argc < 2) return 1;
    FILE *fp = fopen(argv[1], "r");
    if (!fp) return 1;

    char line[128];
    char ip[32] = {0}, gw[32] = {0}, mask[32] = {0};
    int inside_static = 0;

    while (fgets(line, sizeof(line), fp)) {
        /* New subnet block — reset state */
        if (strstr(line, "- type:") || strstr(line, "-  type:")) {
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