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

#define BOOSTER_BIN "booster.bin"

#include "booster.h"

static uint8_t bitstream_buffer[0x1a000];

int main(int argc, char **argv)
{
    struct booster_data booster_data;
    struct stat stat_buf;

    if (argc != 4)
    {
        fprintf(stderr, "Usage: %s [device-id] [infile] [outfile]\n", argv[0]);
        fprintf(stderr, "The device-id is one of the following:\n");
        fprintf(stderr, "    	0xef177018     Evaluation EVT\n");
        fprintf(stderr, "    	0xc2152815     Production PVT\n");
        fprintf(stderr, "    	0x1f148601     Hacker board\n");
        return 1;
    }

    uint32_t device_id = strtoul(argv[1], NULL, 0);
    char *infile_name = argv[2];
    char *outfile_name = argv[3];

    int booster_fd = open(BOOSTER_BIN, O_RDONLY);
    if (booster_fd == -1)
    {
        perror("Unable to open " BOOSTER_BIN " (try running 'make -Iinclude')");
        return 8;
    }
    if (-1 == fstat(booster_fd, &stat_buf))
    {
        perror("Unable to determine size of booster");
        return 4;
    }
    uint32_t booster_size = stat_buf.st_size;
    if (booster_size & 3) {
        fprintf(stderr, "Error: booster_size is not a multiple of 32-bits\n");
        return 1;
    }

    int bitstream_fd = open(infile_name, O_RDONLY);
    if (bitstream_fd == -1)
    {
        perror("Unable to open input bitstream file");
        return 2;
    }
    if (-1 == fstat(bitstream_fd, &stat_buf))
    {
        perror("Unable to determine size of input file");
        return 4;
    }
    uint32_t bitstream_size = stat_buf.st_size;

    int outfile_fd = open(outfile_name, O_WRONLY | O_CREAT | O_TRUNC, 0777);
    if (outfile_fd == -1)
    {
        perror("Unable to open output file");
        return 3;
    }

    // Copy booster into RAM so we can patch it and calculate its size
    uint8_t booster_buffer[booster_size];
    if (read(booster_fd, booster_buffer, sizeof(booster_buffer)) != sizeof(booster_buffer))
    {
        perror("Unable to read booster into RAM");
        return 11;
    }

    // Copy the bitstream into RAM
    memset(bitstream_buffer, 0, sizeof(bitstream_buffer));
    if (read(bitstream_fd, bitstream_buffer, bitstream_size) != bitstream_size)
    {
        perror("Unable to read bitstream into RAM");
        return 11;
    }

    // Patch the bitstream such that it boots to ofset 0x040000
    bitstream_buffer[9] = 0x04;

    // Patch up Booster
    uint32_t booster_sum = 0;
    uint32_t booster_offset = 0;
    for (booster_offset = 0x20; booster_offset < booster_size; booster_offset++)
    {
        booster_sum += booster_buffer[booster_offset];
    }
    uint32_t *booster_ptr = (uint32_t *)booster_buffer;
    // booster_ptr[0] = j crt_init
    booster_ptr[1] = htole32(BOOSTER_SIGNATURE);                                 // booster_signature
    booster_ptr[2] = htole32(booster_size);                                      // booster length
    booster_ptr[3] = htole32(booster_sum);                                       // booster checksum
    booster_ptr[4] = htole32(bitstream_size);                                    // image length
    booster_ptr[5] = htole32(sizeof(bitstream_buffer) + sizeof(booster_buffer)); // hash length
    booster_ptr[6] = htole32(BOOSTER_SEED);                                      // image seed
    booster_ptr[7] = htole32(device_id);                                         // spi id

    uint8_t mega_buffer[sizeof(booster_buffer) + sizeof(bitstream_buffer)];
    memcpy(mega_buffer, bitstream_buffer, sizeof(bitstream_buffer));
    memcpy(mega_buffer + sizeof(bitstream_buffer), booster_buffer, sizeof(booster_buffer));
    booster_data.xxhash = htole32(XXH32(mega_buffer, sizeof(mega_buffer), BOOSTER_SEED));

    if (sizeof(mega_buffer) != write(outfile_fd, mega_buffer, sizeof(mega_buffer)))
    {
        perror("Unable to write image to output file");
        return 12;
    }

    if (sizeof(booster_data) != write(outfile_fd, &booster_data, sizeof(booster_data)))
    {
        perror("Unable to write booster data to output file");
        return 7;
    }

    close(bitstream_fd);
    close(outfile_fd);
    close(booster_fd);
}
