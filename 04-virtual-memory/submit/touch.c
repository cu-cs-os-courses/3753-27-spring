/* Basecamp 4, Part 1 — watch pages materialize.
 *
 * malloc a 64 MiB region, then measure what the kernel actually did:
 * resident set size (VmRSS) and minor page faults, before and after
 * touching one byte in every page. Print exactly three lines:
 *
 *   RSS_KB_BEFORE=<n>
 *   RSS_KB_AFTER=<n>
 *   MINFLT_DELTA=<n>
 *
 * Everything you need is in /proc/self — lab-0 territory.
 *
 * Verify locally with:  make check LAB=04-virtual-memory
 */
#include <stdio.h>
#include <stdlib.h>

#define REGION (64L * 1024 * 1024)
#define PAGE   4096L

/* This process's resident set size in kB: the VmRSS: line of
 * /proc/self/status. Return -1 on failure. */
static long rss_kb(void)
{
    /* TODO */
    return -1;
}

/* This process's cumulative minor-fault count: field 10 of
 * /proc/self/stat. (Field 2, the comm, can contain spaces in general —
 * for THIS program it doesn't, so whitespace splitting is fine.)
 * Return -1 on failure. */
static long minflt(void)
{
    /* TODO */
    return -1;
}

int main(void)
{
    char *region = malloc(REGION);
    if (!region) {
        perror("malloc");
        return 1;
    }

    long rss0 = rss_kb();
    long flt0 = minflt();
    printf("RSS_KB_BEFORE=%ld\n", rss0);

    /* TODO: touch one byte in every PAGE-sized chunk of region. */

    long rss1 = rss_kb();
    long flt1 = minflt();
    printf("RSS_KB_AFTER=%ld\n", rss1);
    printf("MINFLT_DELTA=%ld\n", flt1 - flt0);

    free(region);
    return 0;
}
