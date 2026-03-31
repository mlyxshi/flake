#include <stdio.h>
#include <string.h>

// By Gemini

int main(int argc, char *argv[]) {
    FILE *fp = fopen(argv[1], "r");
    if (!fp) return 1;

    char line[128];
    char ip[32] = {0}, gw[32] = {0}, mask[32] = {0};
    int inside_static = 0;

    while (fgets(line, sizeof(line), fp)) {
        // Only start looking for IP/GW/Mask after we hit 'type: static'
        if (strstr(line, "type: static")) {
            inside_static = 1;
            continue;
        }

        if (inside_static) {
            // sscanf with %*[^']' is a trick to skip everything until the first quote
            // then %31[^'] captures everything until the closing quote
            if (strstr(line, "address:")) 
                sscanf(line, "%*[^']'%31[^']", ip);
            else if (strstr(line, "netmask:")) 
                sscanf(line, "%*[^']'%31[^']", mask);
            else if (strstr(line, "gateway:")) 
                sscanf(line, "%*[^']'%31[^']", gw);
        }
        
        // If we hit a new block (indented 'type'), stop looking in static
        if (inside_static && strstr(line, " - type:") && !strstr(line, "static")) {
            if (ip[0] && gw[0]) break; 
        }
    }

    printf("IP=%s\nGATEWAY=%s\nNETMASK=%s\n", ip, gw, mask);

    fclose(fp);
    return 0;
}