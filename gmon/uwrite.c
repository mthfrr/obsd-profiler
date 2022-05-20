#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ktrace.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/uio.h>

#define __unused __attribute__((unused))

// int utrace(const char *label, void *addr, size_t len);

#define START_SIZE 10

struct gmon_trace
{
    char* label;
    char* data;
    size_t size;
    size_t allocated;
};

struct gmon_trace* utrace_open(char* label, int __unused unused1,
                               int __unused unused2)
{
    struct gmon_trace* t = malloc(sizeof(struct gmon_trace));
    t->label = label;
    t->data = malloc(START_SIZE);
    t->size = 0;
    t->allocated = START_SIZE;
    return t;
}

void utrace_write(struct gmon_trace* t, void* data, size_t size)
{
    while (size + t->size >= t->allocated)
    {
        t->data = realloc(t->data, t->allocated * 2);
        t->allocated *= 2;
    }

    memcpy(t->data + t->size, data, size);
    t->size += size;
}

void utrace_close(struct gmon_trace* t)
{
    utrace(t->label, t->data, t->size);
    free(t->data);
    free(t);
}
