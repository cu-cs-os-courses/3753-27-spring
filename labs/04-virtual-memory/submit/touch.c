/* Basecamp 4, Part 1 — watch pages arrive.
 *
 * malloc a 64 MiB region, then measure what the kernel actually did:
 * resident set size (VmRSS) and page faults, before and after writing
 * one byte into every page. Print exactly three lines:
 *
 *   RSS_KB_BEFORE=<n>
 *   RSS_KB_AFTER=<n>
 *   FAULT_DELTA=<n>
 *
 * Everything you need is in /proc/self.
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

/* This process's page faults since it started: field 10 plus field 12
 * of /proc/self/stat. Fields are numbered from 1, and the PID is field 1.
 * (Field 2, the comm, can contain spaces in general — for THIS program
 * it doesn't, so whitespace splitting is fine.)
 * Return -1 on failure. */
static long faults(void)
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
    long flt0 = faults();
    printf("RSS_KB_BEFORE=%ld\n", rss0);

    /* TODO: write one byte into every PAGE-sized chunk of region. */

    long rss1 = rss_kb();
    long flt1 = faults();
    printf("RSS_KB_AFTER=%ld\n", rss1);
    printf("FAULT_DELTA=%ld\n", flt1 - flt0);

    free(region);
    return 0;
}
