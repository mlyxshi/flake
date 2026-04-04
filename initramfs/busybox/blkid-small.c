/*
 * blkid.c - mimic `blkid` / `blkid -L` By Claude Sonnet 4.6
 *
 * Supports: ext2/3/4, xfs, btrfs, vfat, f2fs, iso9660
 *
 * Build: gcc -O2 -o blkid blkid.c
 * Usage: ./blkid              -> print all block devices; with FS: LABEL + TYPE
 *        ./blkid -L <label>  -> print device path for that label
 * By Claude
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>

/* ── superblock constants ─────────────────────────────────────────────────── */

#define EXT_SB_OFFSET       1024
#define EXT_MAGIC_OFF       56
#define EXT_MAGIC           0xEF53
#define EXT_LABEL_OFF       120
#define EXT_LABEL_LEN       16
#define EXT_COMPAT_OFF      96
#define EXT_INCOMPAT_OFF    100
#define EXT_FEAT_JOURNAL    0x00000004u
#define EXT_FEAT_EXTENTS    0x00000040u
#define EXT_FEAT_64BIT      0x00000080u

#define XFS_MAGIC           "XFSB"
#define XFS_LABEL_OFF       108
#define XFS_LABEL_LEN       12

#define BTRFS_SB_OFFSET     65536
#define BTRFS_MAGIC         "_BHRfS_M"
#define BTRFS_LABEL_OFF     299
#define BTRFS_LABEL_LEN     256

#define FAT_LABEL_OFF_16    43
#define FAT_LABEL_OFF_32    71
#define FAT_LABEL_LEN       11

#define F2FS_SB_OFFSET      4096
#define F2FS_MAGIC          0xF2F52010u
#define F2FS_LABEL_OFF      108
#define F2FS_LABEL_LEN      512

#define ISO_SB_OFFSET       0x8000
#define ISO_LABEL_OFF       40
#define ISO_LABEL_LEN       32

/* ── helpers ──────────────────────────────────────────────────────────────── */

static int read_at(int fd, off_t off, void *buf, size_t len)
{
    if (lseek(fd, off, SEEK_SET) == (off_t)-1) return -1;
    ssize_t n = read(fd, buf, len);
    return (n == (ssize_t)len) ? 0 : -1;
}

static void rtrim(char *s, size_t max)
{
    s[max] = '\0';
    size_t len = strlen(s);
    while (len > 0 && s[len-1] == ' ') s[--len] = '\0';
}

static void utf16le_to_ascii(const uint8_t *src, size_t src_bytes, char *dst, size_t dst_max)
{
    size_t j = 0;
    for (size_t i = 0; i + 1 < src_bytes && j + 1 < dst_max; i += 2) {
        uint16_t c = (uint16_t)(src[i] | (src[i+1] << 8));
        if (c == 0) break;
        if (c < 128) dst[j++] = (char)c;
    }
    dst[j] = '\0';
}

/* ── probes ───────────────────────────────────────────────────────────────── */

static const char *probe_ext(int fd, char *label)
{
    uint8_t sb[136];
    if (read_at(fd, EXT_SB_OFFSET, sb, sizeof sb) < 0) return NULL;
    uint16_t magic;
    memcpy(&magic, sb + EXT_MAGIC_OFF, 2);
    if (magic != EXT_MAGIC) return NULL;
    memcpy(label, sb + EXT_LABEL_OFF, EXT_LABEL_LEN);
    label[EXT_LABEL_LEN] = '\0';
    uint32_t compat, incompat;
    memcpy(&compat,   sb + EXT_COMPAT_OFF,   4);
    memcpy(&incompat, sb + EXT_INCOMPAT_OFF, 4);
    if (incompat & (EXT_FEAT_EXTENTS | EXT_FEAT_64BIT)) return "ext4";
    if (compat   &  EXT_FEAT_JOURNAL)                   return "ext3";
    return "ext2";
}

static const char *probe_xfs(int fd, char *label)
{
    uint8_t sb[512];
    if (read_at(fd, 0, sb, sizeof sb) < 0) return NULL;
    if (memcmp(sb, XFS_MAGIC, 4) != 0) return NULL;
    memcpy(label, sb + XFS_LABEL_OFF, XFS_LABEL_LEN);
    label[XFS_LABEL_LEN] = '\0';
    return "xfs";
}

static const char *probe_btrfs(int fd, char *label)
{
    uint8_t sb[512];
    if (read_at(fd, BTRFS_SB_OFFSET, sb, sizeof sb) < 0) return NULL;
    if (memcmp(sb, BTRFS_MAGIC, 8) != 0) return NULL;
    uint8_t lbuf[BTRFS_LABEL_LEN + 1];
    if (read_at(fd, BTRFS_SB_OFFSET + BTRFS_LABEL_OFF, lbuf, BTRFS_LABEL_LEN) < 0)
        return NULL;
    lbuf[BTRFS_LABEL_LEN] = '\0';
    memcpy(label, lbuf, BTRFS_LABEL_LEN + 1);
    return "btrfs";
}

static const char *probe_vfat(int fd, char *label)
{
    uint8_t sb[512];
    if (read_at(fd, 0, sb, sizeof sb) < 0) return NULL;
    if (memcmp(sb + 82, "FAT32   ", 8) == 0) {
        memcpy(label, sb + FAT_LABEL_OFF_32, FAT_LABEL_LEN);
        label[FAT_LABEL_LEN] = '\0';
        rtrim(label, FAT_LABEL_LEN);
        if (strcmp(label, "NO NAME") == 0) label[0] = '\0';
        return "vfat";
    }
    if (memcmp(sb + 54, "FAT", 3) == 0) {
        memcpy(label, sb + FAT_LABEL_OFF_16, FAT_LABEL_LEN);
        label[FAT_LABEL_LEN] = '\0';
        rtrim(label, FAT_LABEL_LEN);
        if (strcmp(label, "NO NAME") == 0) label[0] = '\0';
        return "vfat";
    }
    return NULL;
}

static const char *probe_f2fs(int fd, char *label)
{
    uint8_t sb[F2FS_LABEL_OFF + F2FS_LABEL_LEN];
    if (read_at(fd, F2FS_SB_OFFSET, sb, sizeof sb) < 0) return NULL;
    uint32_t magic;
    memcpy(&magic, sb, 4);
    if (magic != F2FS_MAGIC) return NULL;
    utf16le_to_ascii(sb + F2FS_LABEL_OFF, F2FS_LABEL_LEN, label, 255);
    return "f2fs";
}

static const char *probe_iso(int fd, char *label)
{
    uint8_t sb[ISO_LABEL_OFF + ISO_LABEL_LEN + 1];
    if (read_at(fd, ISO_SB_OFFSET, sb, sizeof sb) < 0) return NULL;
    if (sb[0] != 1 || memcmp(sb + 1, "CD001", 5) != 0) return NULL;
    memcpy(label, sb + ISO_LABEL_OFF, ISO_LABEL_LEN);
    label[ISO_LABEL_LEN] = '\0';
    rtrim(label, ISO_LABEL_LEN);
    return "iso9660";
}

static const char *probe_device(const char *path, char *label)
{
    label[0] = '\0';
    int fd = open(path, O_RDONLY | O_NONBLOCK);
    if (fd < 0) return NULL;

    char buf[512] = {0};
    const char *fstype = NULL;

    if      ((fstype = probe_ext(fd, buf)))   {}
    else if ((fstype = probe_xfs(fd, buf)))   {}
    else if ((fstype = probe_btrfs(fd, buf))) {}
    else if ((fstype = probe_vfat(fd, buf)))  {}
    else if ((fstype = probe_f2fs(fd, buf)))  {}
    else if ((fstype = probe_iso(fd, buf)))   {}

    close(fd);
    if (fstype) { memcpy(label, buf, 511); label[511] = '\0'; }
    return fstype;
}

/* ── enumeration ──────────────────────────────────────────────────────────── */

static int is_block_device(const char *path)
{
    struct stat st;
    return stat(path, &st) == 0 && S_ISBLK(st.st_mode);
}

static void scan(const char *want_label)
{
    DIR *d = opendir("/sys/class/block");
    if (!d) { perror("opendir /sys/class/block"); return; }

    char **names = NULL;
    size_t count = 0, cap = 0;
    struct dirent *ent;

    while ((ent = readdir(d)) != NULL) {
        if (ent->d_name[0] == '.') continue;
        if (strncmp(ent->d_name, "loop", 4) == 0) continue;
        if (count >= cap) {
            cap = cap ? cap * 2 : 64;
            names = realloc(names, cap * sizeof *names);
        }
        names[count++] = strdup(ent->d_name);
    }
    closedir(d);

    for (size_t i = 0; i < count; i++)
        for (size_t j = i+1; j < count; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char *tmp = names[i]; names[i] = names[j]; names[j] = tmp;
            }

    for (size_t i = 0; i < count; i++) {
        char devpath[256];
        snprintf(devpath, sizeof devpath, "/dev/%s", names[i]);

        if (!is_block_device(devpath)) { free(names[i]); continue; }

        char label[512];
        const char *fstype = probe_device(devpath, label);

        if (want_label) {
            if (fstype && label[0] != '\0' && strcmp(label, want_label) == 0) {
                printf("%s\n", devpath);
                for (size_t j = i; j < count; j++) free(names[j]);
                free(names);
                exit(0);
            }
        } else {
            if (fstype)
                printf("%s: LABEL=\"%s\" TYPE=\"%s\"\n", devpath, label, fstype);
            else
                printf("%s\n", devpath);
        }
        free(names[i]);
    }
    free(names);

    if (want_label) exit(2);
}

/* ── main ─────────────────────────────────────────────────────────────────── */

int main(int argc, char *argv[])
{
    if (argc == 1) {
        scan(NULL);
        return 0;
    }

    const char *label = NULL;
    if (argc == 3 &&
        (strcmp(argv[1], "-L") == 0 || strcmp(argv[1], "--label") == 0)) {
        label = argv[2];
    } else if (argc == 2 && strncmp(argv[1], "--label=", 8) == 0) {
        label = argv[1] + 8;
    } else {
        fprintf(stderr,
                "Usage: %s\n"
                "       %s -L <label>\n"
                "       %s --label=<label>\n",
                argv[0], argv[0], argv[0]);
        return 1;
    }

    scan(label);
    return 0;
}