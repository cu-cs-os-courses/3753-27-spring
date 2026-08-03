/* Basecamp 3, Part 1 — see the race.
 *
 * Usage: race racy|locked
 *
 * NTHREADS threads each increment the shared counter NITER times.
 *   racy:   bare counter++            — the demonstration
 *   locked: counter++ under the mutex — the remedy
 * Then main prints exactly:  COUNT=<n>
 *
 * Rule: racy mode must actually race. No atomics — the checks look.
 *
 * Verify locally with:  make check LAB=03-concurrency
 */
#include <pthread.h>
#include <stdio.h>
#include <string.h>

#define NTHREADS 4
#define NITER    200000

long counter = 0;
int use_lock = 0;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

void *worker(void *arg)
{
    (void)arg;
    /* TODO: NITER times — if use_lock, increment counter with the
     * mutex held; otherwise increment it bare. */

    return NULL;
}

int main(int argc, char *argv[])
{
    if (argc != 2 ||
        (strcmp(argv[1], "racy") != 0 && strcmp(argv[1], "locked") != 0)) {
        fprintf(stderr, "usage: %s racy|locked\n", argv[0]);
        return 2;
    }
    use_lock = strcmp(argv[1], "locked") == 0;

    /* TODO: create NTHREADS workers, then join them all. */

    printf("COUNT=%ld\n", counter);
    return 0;
}
