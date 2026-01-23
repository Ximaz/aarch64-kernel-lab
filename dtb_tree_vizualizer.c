#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define READ_CHUNK 1024

#define FDT_BEGIN_NODE 0x00000001
#define FDT_END_NODE 0x00000002
#define FDT_PROP 0x00000003
#define FDT_NOP 0x00000004
#define FDT_END 0x00000009

struct fdt_header {
  uint32_t magic;
  uint32_t totalsize;
  uint32_t off_dt_struct;
  uint32_t off_dt_strings;
  uint32_t off_mem_rsvmap;
  uint32_t version;
  uint32_t last_comp_version;
  uint32_t boot_cpuid_phys;
  uint32_t size_dt_strings;
  uint32_t size_dt_struct;
};

struct dt_blob {
  struct fdt_header header;
  uint8_t *buffer;
};

#define TOLITEND32(V)                                                          \
  ((((V) & 0x000000FF) >> 0) << 24 | (((V) & 0x0000FF00) >> 8) << 16 |         \
   (((V) & 0x00FF0000) >> 16) << 8 | (((V) & 0xFF000000) >> 24) << 0)

static void dump_cursor(const uint32_t *cursor, uint64_t size) {
  for (uint64_t i = 0; i < (size >> 4); ++i, cursor += 4) {
    printf("%p: ", cursor);
    for (uint64_t j = 0; j < 16; ++j) {
      uint8_t byte = *((const char *)(cursor) + j);
      printf("%02x ", byte);
    }
    printf("\n");
  }
}

static struct dt_blob *load_device_tree_blob(const char *filepath) {
  size_t cursor = 0;
  size_t filesize = 0;
  uint8_t *buffer = NULL;
  ssize_t read_bytes = 0;
  struct dt_blob *dt_blob = NULL;
  FILE *fp = fopen(filepath, "r");

  if (NULL == fp) {
    perror("fopen");
    return NULL;
  }

  fseek(fp, 0, SEEK_END);
  filesize = ftello(fp);
  fseek(fp, 0, SEEK_SET);
  if (0 == filesize) {
    fclose(fp);
    perror("ftello");
    return NULL;
  }

  buffer = malloc(sizeof(uint8_t) * filesize);
  if (NULL == buffer) {
    fclose(fp);
    perror("buffer");
    return NULL;
  }

  while (cursor < filesize) {
    read_bytes = fread(buffer + cursor, sizeof(uint8_t), READ_CHUNK, fp);
    if (read_bytes < 0) {
      free(buffer);
      fclose(fp);
      perror("fread");
      return NULL;
    }
    cursor += read_bytes;
  }
  fclose(fp);

  dt_blob = malloc(sizeof(struct dt_blob));
  if (NULL == dt_blob) {
    free(buffer);
    perror("malloc");
    return NULL;
  }
  dt_blob->buffer = buffer;
  memcpy(&dt_blob->header, buffer, sizeof(struct fdt_header));
  return dt_blob;
}

static int8_t print_device_tree_blob_metadata(const struct dt_blob *dt_blob) {
  if (TOLITEND32(dt_blob->header.magic) != 0xd00dfeedU) {
    fprintf(stderr, "Invalid DTB magic number: %x\n",
            TOLITEND32(dt_blob->header.magic));
    return EXIT_FAILURE;
  }
  printf("Device tree metadata :\n");
  printf("- total size : %u\n", TOLITEND32(dt_blob->header.totalsize));
  printf("- version : %u\n", TOLITEND32(dt_blob->header.version));
  printf("- last compatible version : %u\n",
         TOLITEND32(dt_blob->header.last_comp_version));
  printf("- boot physical CPU id : %u\n",
         TOLITEND32(dt_blob->header.boot_cpuid_phys));
  printf("- strings size : %u\n", TOLITEND32(dt_blob->header.size_dt_strings));
  printf("- structures size : %u\n",
         TOLITEND32(dt_blob->header.size_dt_struct));
  printf("\n");
  return EXIT_SUCCESS;
}

#define NEXT_ALIGNED_CURSOR(C, O) (uint32_t *)(((uintptr_t)(C)) + (O) + 3 & ~3)

static uint8_t is_string(const uint32_t *cursor, uint32_t size) {
  const char *buffer = (const char *)cursor;

  for (uint64_t i = 0; i < size; ++i) {
    if (buffer[i] == 0 || !isprint(buffer[i])) {
      return 0;
    }
  }
  return buffer[size] == 0;
}
static uint8_t is_string_array(const uint32_t *cursor, uint32_t size) {
  uint64_t i = 0;
  const char *buffer = (const char *)cursor;

  while (i < size) {
    if (!is_string((const uint32_t *)buffer, strlen(buffer))) {
      return 0;
    }
    i += strlen(buffer);
  }
  return 1;
}

static uint32_t *print_device_tree_node_property(const struct dt_blob *dt_blob,
                                                 uint32_t *cursor) {
  uint32_t prop_value_size = 0;
  const char *prop_name = NULL;
  const char *strings_ptr =
      (const char *)(dt_blob->buffer +
                     TOLITEND32(dt_blob->header.off_dt_strings));
  if (TOLITEND32(*cursor) != FDT_PROP) {
    return cursor;
  }
  ++cursor;
  prop_value_size = TOLITEND32(*cursor);
  ++cursor;
  prop_name = strings_ptr + TOLITEND32(*cursor);
  ++cursor;

  printf("  %s = <", prop_name);
  if ((strcmp(prop_name, "compatible") == 0 ||
       strcmp(prop_name, "clock-names") == 0) &&
      is_string_array(cursor, prop_value_size)) {
    for (uint64_t i = 0; i < prop_value_size - 1; ++i) {
      uint8_t byte = *((const uint8_t *)cursor + i);
      if (byte == 0) {
        printf(">, <");
      } else {
        printf("%c", byte);
      }
    }
  } else if (strcmp(prop_name, "compatible") == 0 ||
             strcmp(prop_name, "model") == 0 ||
             strcmp(prop_name, "status") == 0 ||
             strcmp(prop_name, "device_type") == 0 ||
             is_string(cursor, prop_value_size - 1)) {
    for (uint64_t i = 0; i < prop_value_size - 1; ++i) {
      uint8_t byte = *((const uint8_t *)cursor + i);
      printf("%c", byte);
    }
  } else {
    for (uint64_t i = 0; i < prop_value_size; ++i) {
      uint8_t byte = *((const uint8_t *)cursor + i);
      printf("%02x", byte);
      if (i < prop_value_size - 1) {
        printf(" ");
      }
    }
  }
  printf(">;\n");
  cursor = NEXT_ALIGNED_CURSOR(cursor, prop_value_size);
  return cursor;
}

static uint32_t *print_device_tree_node(const struct dt_blob *dt_blob,
                                        uint32_t *cursor) {
  uint64_t node_unit_name_len = 0;

  if (TOLITEND32(*cursor) != FDT_BEGIN_NODE) {
    return cursor;
  }
  ++cursor;
  node_unit_name_len = strlen((const char *)cursor);
  printf("%s {\n", (node_unit_name_len == 0) ? "/" : (const char *)cursor);
  cursor = NEXT_ALIGNED_CURSOR(cursor, node_unit_name_len + 1);
  while (TOLITEND32(*cursor) == FDT_PROP) {
    cursor = print_device_tree_node_property(dt_blob, cursor);
    while (TOLITEND32(*cursor) == FDT_NOP) {
      ++cursor;
    }
  }
  printf("}\n");
  return cursor;
}

static int8_t print_device_tree_blob(const struct dt_blob *dt_blob) {
  if (EXIT_FAILURE == print_device_tree_blob_metadata(dt_blob)) {
    return EXIT_FAILURE;
  }
  uint32_t *cursor =
      (uint32_t *)(dt_blob->buffer + TOLITEND32(dt_blob->header.off_dt_struct));

  while (TOLITEND32(*cursor) == FDT_BEGIN_NODE) {
    cursor = print_device_tree_node(dt_blob, cursor);
    while (TOLITEND32(*cursor) == FDT_END_NODE) {
      ++cursor;
    }
  }
  if (TOLITEND32(*cursor) != FDT_END) {
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}

int main(int argc, char const *argv[]) {
  int8_t status = EXIT_FAILURE;
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <dtb_file_path>\n", argv[0]);
    return status;
  }
  const char *filepath = argv[1];
  struct dt_blob *dt_blob = load_device_tree_blob(filepath);
  if (NULL == dt_blob) {
    return status;
  }
  status = print_device_tree_blob(dt_blob);
  free(dt_blob->buffer);
  free(dt_blob);
  return status;
}
