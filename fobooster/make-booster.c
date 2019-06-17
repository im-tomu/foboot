#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#ifdef __APPLE__
#include <libkern/OSByteOrder.h>
#define htole32(x) OSSwapHostToLittleInt32(x)
#else
#include <endian.h>
#endif

#define FOBOOSTER_BIN "fobooster.bin"

#include "fobooster.h"

int main(int argc, char **argv) {
    int i;
    struct fobooster_data booster_data;

    if (argc != 4) {
        fprintf(stderr, "Usage: %s [device-id] [infile] [outfile]\n", argv[0]);
        fprintf(stderr, "The device-id is one of the following:\n");
        fprintf(stderr, "    	0xef177018     Evaluation EVT\n");
        fprintf(stderr, "    	0xc2152815     Production PVT\n");
        return 1;
    }

    uint32_t device_id = strtoul(argv[1], NULL, 0);
    char *infile_name = argv[2];
    char *outfile_name = argv[3];

    int booster_fd = open(FOBOOSTER_BIN, O_RDONLY);
    if (booster_fd == -1) {
        perror("Unable to open " FOBOOSTER_BIN);
        return 8;
    }

    int infile_fd = open(infile_name, O_RDONLY);
    if (infile_fd == -1) {
        perror("Unable to open input file");
        return 2;
    }

    int outfile_fd = open(outfile_name, O_WRONLY | O_CREAT | O_TRUNC, 0777);
    if (outfile_fd == -1) {
        perror("Unable to open output file");
        return 3;
    }

    struct stat stat_buf;
    if (-1 == fstat(infile_fd, &stat_buf)) {
        perror("Unable to determine size of input file");
        return 4;
    }

    // Copy the contents of the booster program
    while (1) {
        uint8_t b;
        if (sizeof(b) != read(booster_fd, &b, sizeof(b))) {
            break;
        }

        if (sizeof(b) != write(outfile_fd, &b, sizeof(b))) {
            perror("Unable to write to output file");
            return 10;
        }
    }

    uint8_t toboot_buffer[stat_buf.st_size];
    if (read(infile_fd, toboot_buffer, sizeof(toboot_buffer)) != sizeof(toboot_buffer)) {
        perror("Unable to read input file into RAM");
        return 11;
    }

    booster_data.payload_size = htole32(stat_buf.st_size);
    booster_data.device_id = htole32(device_id);
    booster_data.xxhash = htole32(XXH32(toboot_buffer, sizeof(toboot_buffer), FOBOOSTER_SEED));

    if (sizeof(booster_data) != write(outfile_fd, &booster_data, sizeof(booster_data))) {
        perror("Unable to write booster header to output file");
        return 12;
    }

    if (sizeof(toboot_buffer) != write(outfile_fd, toboot_buffer, sizeof(toboot_buffer))) {
        perror("Unable to write new bootloader to output file");
        return 7;
    }

    close(infile_fd);
    close(outfile_fd);
    close(booster_fd);
}
