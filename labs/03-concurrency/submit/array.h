/* Basecamp 3, Part 2 — the bounded buffer: interface.
 *
 * You own this header: define the array struct that the four
 * functions below need. It wants storage for ARRAY_SIZE char*
 * payloads, whatever bookkeeping your implementation uses, one
 * pthread_mutex_t, and two pthread_cond_t (space available / items
 * available). The stack worked example in the Lab03 walkthrough shows the shape.
 */
#pragma once
#include <pthread.h>

#define ARRAY_SIZE 8    /* max elements */

typedef struct {
    /* TODO: storage, bookkeeping, mutex, two condition variables. */
    int todo_delete_me; /* placeholder so the starter compiles */
} array;

int  array_init(array *s);                  /* initialise; 0 on success */
int  array_put (array *s, char *hostname);  /* add;    BLOCKS while full  */
int  array_get (array *s, char **hostname); /* remove; BLOCKS while empty */
void array_free(array *s);                  /* release the array's resources */
