#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <string.h>
#include <termios.h>

int read_exactly(int fd, uint8_t *bfr, size_t len) {
	size_t off = 0;
	int op_len;
	while (off < len) {
		op_len = read(fd, bfr + off, len - off);
		if (-1 == op_len) {
			perror("Couldn't read");
			return -1;
		}
		if (!op_len) {
			fprintf(stderr, "Serial is gone\n");
			return -1;
		}
		off += op_len;

//		if (op_len != len) {
//			fprintf(stderr, "WARNING: wanted to read %d bytes, but read %d\n", len, op_len);
//		}
	}
	return op_len;
}


int main(int argc, char **argv) {
	struct termios  tty;
	unsigned int max_packet_size = 64;
	int fd = open("/dev/ttyACM0", O_RDWR | O_NOCTTY);
	int loop_count = 0;
	if (-1 == fd) {
		perror("Couldn't open!");
		return 1;
	}

	tcgetattr(fd, &tty);
	cfmakeraw(&tty);
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;    /* no HW flow control? */
	tty.c_cflag |= CLOCAL | CREAD;
	tcsetattr(fd, TCSANOW, &tty);

	while (1) {
		uint8_t out_bfr[max_packet_size];
		uint8_t in_bfr[sizeof(out_bfr)];
		unsigned int rand_len = random() % sizeof(in_bfr);
		int op_len;
		int i;

		memset(in_bfr, 0, sizeof(in_bfr));
		memset(out_bfr, 0, sizeof(in_bfr));
		loop_count++;
		if (!rand_len)
			continue;
		for (i = 0; i < rand_len; i++) {
			out_bfr[i] = random();
		}

		op_len = write(fd, out_bfr, rand_len);
		if (-1 == op_len) {
			perror("Couldn't write");
			return 1;
		}

		if (!op_len) {
			fprintf(stderr, "Serial is gone\n");
			return 1;
		}

		if (op_len != rand_len) {
			fprintf(stderr, "Wanted to write %d bytes, but wrote %d\n", rand_len, op_len);
			return 1;
		}

		if (read_exactly(fd, in_bfr, rand_len) < 0) {
			return 1;
		}

		int errored = 0;
		for (i = 0; i < op_len; i++) {
			if (in_bfr[i] != ((out_bfr[i]+1)&0xff) ) {
				errored = 1;
				fprintf(stderr, "loop %d:  i: %d  Expected %02x, got %02x\n",
						loop_count, i,
						(out_bfr[i] + 1) & 0xff,
					        in_bfr[i]);
			}
		}
		if (errored)
			return 1;

		if ((loop_count % 100) == 0) {
			fprintf(stderr, "loop %d\n", loop_count);
		}
	}

	return 0;
}
