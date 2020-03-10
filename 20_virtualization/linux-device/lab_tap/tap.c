#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <linux/if_tun.h>
#include <linux/ioctl.h>

#define IFNAMSIZ 16

int tun_alloc(char *dev, int flags) {

	struct ifreq ifr;
	int fd, err;
	char *clonedev = "/dev/net/tun";

	/* Arguments taken by the function:
	 *
	 * char *dev: the name of an interface (or '\0'). MUST have enough
	 *   space to hold the interface name if '\0' is passed
	 * int flags: interface flags (eg, IFF_TUN etc.)
	 */

	/* open the clone device */
	if( (fd = open(clonedev, O_RDWR)) < 0 ) {
		return fd;
	}

	/* preparation of the struct ifr, of type "struct ifreq" */
	memset(&ifr, 0, sizeof(ifr));

	ifr.ifr_flags = flags;   /* IFF_TUN or IFF_TAP, plus maybe IFF_NO_PI */

	if (*dev) {
		/* if a device name was specified, put it in the structure; otherwise,
		 * the kernel will try to allocate the "next" device of the
		 * specified type */
		strncpy(ifr.ifr_name, dev, IFNAMSIZ);
	}

	/* try to create the device */
	if( (err = ioctl(fd, TUNSETIFF, (void *) &ifr)) < 0 ) {
		close(fd);
		return err;
	}

	/* if the operation was successful, write back the name of the
	 * interface to the variable "dev", so the caller can know
	 * it. Note that the caller MUST reserve space in *dev (see calling
	 * code below) */
	strcpy(dev, ifr.ifr_name);

	/* this is the special file descriptor that the caller will use to talk
	 * with the virtual interface */
	return fd;
}

int main(void) {
	char tap_name[IFNAMSIZ];
	int nread, tap_fd, i;
	char buffer[2048];
	/* Connect to the device */
	strcpy(tap_name, "tap89");
	tap_fd = tun_alloc(tap_name, IFF_TAP | IFF_NO_PI);  /* tun interface */

	if (tap_fd < 0){
		perror("Allocating interface");
		exit(1);
	} else {
		printf("connected to %s on fd: %i\n", tap_name, tap_fd);
	}

	sleep(2);
	i = 0;
	/* Now read data coming from the kernel */
	while (1) {
		/* Note that "buffer" should be at least the MTU size of the interface, eg 1500 bytes */
		//nread = read(tap_fd, buffer, sizeof(buffer));
		memset(buffer, 0, sizeof(buffer));
		buffer[0] = 0xff;
		buffer[1] = 0xff;
		buffer[2] = 0xff;
		buffer[3] = 0xff;
		buffer[4] = 0xff;
		buffer[5] = 0xff;
		buffer[6] = 0x00;
		buffer[7] = 0x07;
		buffer[8] = 0x0d;
		buffer[9] = 0xaf;
		buffer[10] = 0xf4;
		buffer[11] = 0x54;
		buffer[12] = 0x08;
		buffer[13] = 0x06;
		buffer[14] = 0x00;
		buffer[15] = 0x01;
		buffer[16] = 0x08;
		buffer[17] = 0x00;
		buffer[18] = 0x06;
		buffer[19] = 0x04;
		buffer[20] = 0x00;
		buffer[21] = 0x01;
		buffer[22] = 0x00;
		buffer[23] = 0x07;
		buffer[24] = 0x0d;
		buffer[25] = 0xaf;
		buffer[26] = 0xf4;
		buffer[27] = 0x54;
		buffer[28] = 0x18;
		buffer[29] = 0xa6;
		buffer[30] = 0xac;
		buffer[31] = 0x01;
		buffer[32] = 0x00;
		buffer[33] = 0x00;
		buffer[34] = 0x00;
		buffer[35] = 0x00;
		buffer[36] = 0x00;
		buffer[37] = 0x00;
		buffer[38] = 0x18;
		buffer[39] = 0xa6;
		buffer[40] = 0xad;
		buffer[41] = 0xa8;
		buffer[42] = 0x01;
		buffer[43] = 0x01;
		buffer[44] = 0x04;
		buffer[45] = 0x00;
		buffer[46] = 0x00;
		buffer[47] = 0x00;
		buffer[48] = 0x00;
		buffer[49] = 0x02;
		buffer[50] = 0x01;
		buffer[51] = 0x00;
		buffer[52] = 0x03;
		buffer[53] = 0x02;
		buffer[54] = 0x00;
		buffer[55] = 0x00;
		buffer[56] = 0x05;
		buffer[57] = 0x01;
		buffer[58] = 0x03;
		buffer[59] = 0x01;
		nread = write(tap_fd, buffer, sizeof(buffer));
		if (nread < 0) {
			perror("Reading from interface");
			close(tap_fd);
			exit(1);
		}

		/* Do whatever with the data */
		printf("Read %d bytes from device %s\n", nread, tap_name);
		if(i >= 2)
			return EXIT_SUCCESS;
		i++;
	}
	return EXIT_SUCCESS;
}

