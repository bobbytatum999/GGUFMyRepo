#include <stdint.h>
#ifdef __APPLE__
#include <os/proc.h>
#endif

int64_t gguf_available_ram_bytes(void) {
#ifdef __APPLE__
    return (int64_t)os_proc_available_memory();
#else
    return 0;
#endif
}
