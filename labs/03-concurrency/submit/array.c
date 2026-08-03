/* Basecamp 3, Part 2 — the bounded buffer: implementation.
 *
 * Fill in the four functions. The contract lives in array.h and the
 * README; the short version: put blocks while full, get blocks while
 * empty, both via condition variables (a waiting thread burns ~zero
 * CPU — one of the checks measures that), and the array stores the
 * pointers themselves.
 *
 * Verify locally with:  make check LAB=03-concurrency
 */
#include "array.h"

int array_init(array *s)
{
    /* TODO */
    (void)s;
    return -1;
}

int array_put(array *s, char *hostname)
{
    /* TODO */
    (void)s;
    (void)hostname;
    return -1;
}

int array_get(array *s, char **hostname)
{
    /* TODO */
    (void)s;
    (void)hostname;
    return -1;
}

void array_free(array *s)
{
    /* TODO */
    (void)s;
}
