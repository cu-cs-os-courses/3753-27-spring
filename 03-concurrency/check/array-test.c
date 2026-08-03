/* Basecamp 3 instructor harness. Not secret — read it.
 *
 * Compiled in the guest against the submission:
 *   gcc -Wall -Werror -O2 -pthread -I<submit> array-test.c <submit>/array.c
 *
 * Usage: array-test roundtrip|blocks-empty|blocks-full|stress
 * Exit 0 = scenario passed. Every scenario is deadlock-guarded by
 * alarm(): a hung submission is killed, which is a FAIL, not a stuck
 * grader.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/resource.h>
#include "array.h"

static array arr;

static volatile int flag;
static char *got_item;

static void *consumer_one(void *arg)
{
    (void)arg;
    char *s = NULL;
    if (array_get(&arr, &s) == 0)
        got_item = s;
    flag = 1;
    return NULL;
}

static void *producer_one(void *arg)
{
    (void)arg;
    array_put(&arr, (char *)"ninth");
    flag = 1;
    return NULL;
}

static double cpu_seconds(void)
{
    struct rusage ru;
    getrusage(RUSAGE_SELF, &ru);
    return ru.ru_utime.tv_sec + ru.ru_stime.tv_sec +
           (ru.ru_utime.tv_usec + ru.ru_stime.tv_usec) / 1e6;
}

#define NPROD 2
#define NCONS 2
#define PER   500
#define TOTAL (NPROD * PER)

static char *consumed[TOTAL];
static pthread_mutex_t reclock = PTHREAD_MUTEX_INITIALIZER;
static int recidx;

static void *producer(void *arg)
{
    long id = (long)arg;
    for (int i = 0; i < PER; i++) {
        char *s = malloc(32);
        snprintf(s, 32, "p%ld-%d", id, i);
        if (array_put(&arr, s) != 0)
            exit(9);
    }
    return NULL;
}

static void *consumer(void *arg)
{
    (void)arg;
    for (int i = 0; i < PER; i++) {
        char *s = NULL;
        if (array_get(&arr, &s) != 0 || !s)
            exit(9);
        pthread_mutex_lock(&reclock);
        consumed[recidx++] = s;
        pthread_mutex_unlock(&reclock);
    }
    return NULL;
}

static int cmpstr(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

int main(int argc, char *argv[])
{
    if (argc != 2)
        return 2;
    alarm(20); /* deadlock guard */

    if (strcmp(argv[1], "roundtrip") == 0) {
        char *in[3] = {(char *)"alpha", (char *)"beta", (char *)"gamma"};
        char *out[3];
        int seen[3] = {0, 0, 0};
        if (array_init(&arr) != 0) { puts("FAIL init"); return 1; }
        for (int i = 0; i < 3; i++)
            if (array_put(&arr, in[i]) != 0) { puts("FAIL put"); return 1; }
        for (int i = 0; i < 3; i++)
            if (array_get(&arr, &out[i]) != 0 || !out[i]) { puts("FAIL get"); return 1; }
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                if (strcmp(out[i], in[j]) == 0 && !seen[j]) { seen[j] = 1; break; }
        if (!(seen[0] && seen[1] && seen[2])) { puts("FAIL multiset"); return 1; }
        array_free(&arr);
        puts("OK roundtrip");
        return 0;
    }

    if (strcmp(argv[1], "blocks-empty") == 0) {
        pthread_t t;
        if (array_init(&arr) != 0) { puts("FAIL init"); return 1; }
        flag = 0;
        double c0 = cpu_seconds();
        pthread_create(&t, NULL, consumer_one, NULL);
        sleep(1); /* consumer must still be blocked, burning ~no CPU */
        double waited = cpu_seconds() - c0;
        if (flag) { puts("FAIL returned-early"); return 1; }
        if (array_put(&arr, (char *)"wake") != 0) { puts("FAIL put"); return 1; }
        pthread_join(t, NULL);
        if (!flag || !got_item || strcmp(got_item, "wake") != 0) {
            puts("FAIL wrong-item");
            return 1;
        }
        array_free(&arr);
        printf("CPU_MS=%d\n", (int)(waited * 1000));
        puts("OK blocks-empty");
        return 0;
    }

    if (strcmp(argv[1], "blocks-full") == 0) {
        pthread_t t;
        static char names[ARRAY_SIZE][8];
        char *out = NULL;
        if (array_init(&arr) != 0) { puts("FAIL init"); return 1; }
        for (int i = 0; i < ARRAY_SIZE; i++) {
            snprintf(names[i], sizeof names[i], "f%d", i);
            if (array_put(&arr, names[i]) != 0) { puts("FAIL fill"); return 1; }
        }
        flag = 0;
        pthread_create(&t, NULL, producer_one, NULL);
        sleep(1); /* the 9th put must still be blocked */
        if (flag) { puts("FAIL not-blocked"); return 1; }
        if (array_get(&arr, &out) != 0) { puts("FAIL get"); return 1; }
        pthread_join(t, NULL);
        if (!flag) { puts("FAIL never-woke"); return 1; }
        array_free(&arr);
        puts("OK blocks-full");
        return 0;
    }

    if (strcmp(argv[1], "stress") == 0) {
        pthread_t p[NPROD], c[NCONS];
        char *expected[TOTAL];
        if (array_init(&arr) != 0) { puts("FAIL init"); return 1; }
        for (long i = 0; i < NPROD; i++)
            pthread_create(&p[i], NULL, producer, (void *)i);
        for (int i = 0; i < NCONS; i++)
            pthread_create(&c[i], NULL, consumer, NULL);
        for (int i = 0; i < NPROD; i++)
            pthread_join(p[i], NULL);
        for (int i = 0; i < NCONS; i++)
            pthread_join(c[i], NULL);
        if (recidx != TOTAL) { puts("FAIL count"); return 1; }
        for (long id = 0; id < NPROD; id++)
            for (int i = 0; i < PER; i++) {
                char *s = malloc(32);
                snprintf(s, 32, "p%ld-%d", id, i);
                expected[id * PER + i] = s;
            }
        qsort(consumed, TOTAL, sizeof *consumed, cmpstr);
        qsort(expected, TOTAL, sizeof *expected, cmpstr);
        for (int i = 0; i < TOTAL; i++)
            if (strcmp(consumed[i], expected[i]) != 0) {
                puts("FAIL multiset");
                return 1;
            }
        array_free(&arr);
        puts("OK stress");
        return 0;
    }

    return 2;
}
