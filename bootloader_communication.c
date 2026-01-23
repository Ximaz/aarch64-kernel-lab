#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

static uint64_t get_file_size(FILE *file) {
  uint64_t size = 0;

  fseek(file, SEEK_SET, SEEK_END);
  size = ftello(file);
  fseek(file, SEEK_SET, 0);
  return size;
}

static int read_file(FILE *file, uint8_t *dest, uint64_t size) {
  uint64_t read_bytes = 0;
  int64_t fread_value = 0;

  while (read_bytes < size) {
    fread_value = fread(dest, sizeof(uint8_t), 1024, file);
    if (fread_value <= 0) {
      return fread_value;
    }
    read_bytes += fread_value;
    dest += fread_value;
  }
  return 0;
}

static void send_buffer_to_qemu(const char *qemu_com_sock,
                                const uint8_t *buffer, uint64_t size) {
  printf("Creating the UNIX socket\n");
  int sock = socket(AF_UNIX, SOCK_STREAM, 0);
  if (-1 == sock) {
    perror("socket");
    return;
  }
  struct sockaddr_un addr = {.sun_family = AF_UNIX};
  strncpy(addr.sun_path, qemu_com_sock, sizeof(addr.sun_path));
  printf("Bound socket address: %s\n", addr.sun_path);
  if (-1 == connect(sock, (struct sockaddr *)&addr, sizeof(addr))) {
    close(sock);
    perror("connect");
    return;
  }
  printf("UNIX socket opened\n");
  for (uint64_t i = 0; i < size; ++i, ++buffer) {
      printf("Sending byte %llu...\n", i);
      write(sock, buffer, 1);
      printf("Byte %llu sent\n", i);
  }
  printf("%llu bytes sent to the UNIX socket\n", size);
  close(sock);
}

int main(int argc, const char *argv[]) {
  if (argc != 3) {
    printf("%s <qemu_com_sock> <kernel.img>\n", argv[0]);
    return -1;
  }
  const char *qemu_com_sock = argv[1];
  const char *kernel_img_path = argv[2];

  printf("Reading kernel image from %s\n", kernel_img_path);
  FILE *file = fopen(kernel_img_path, "r");
  if (NULL == file) {
    perror("fopen");
    return 1;
  }
  printf("Gathering facts around kernel image\n");
  uint64_t size = get_file_size(file);
  if (0 == size) {
    fclose(file);
    fprintf(stderr, "Invalid QEMU_COM_SOCK file: file is empty\n");
    return 1;
  }
  printf("%llu bytes are stored in the kernel image\n", size);
  uint8_t *buffer = malloc(size);
  printf("Reading the kernel bytes\n");
  if (-1 == read_file(file, buffer, size)) {
    perror("fread");
    fclose(file);
    free(buffer);
    return 1;
  }
  printf("Closing the kernel file stream\n");
  fclose(file);
  printf("Sending the kernel bytes to the QEMU guest (UNIX socket: %s)\n",
         qemu_com_sock);
    send_buffer_to_qemu(qemu_com_sock, buffer, size);
  printf("Releasing memory\n");
  free(buffer);
  return 0;
}