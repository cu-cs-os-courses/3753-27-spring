# Basecamp 3: The Trouble with Threads

Camps 1 and 2 watched processes compete for the CPU. This camp moves
the competition *inside* one process: threads share an address space,
and sharing without discipline corrupts data — nondeterministically,
which is what makes it the hardest class of bug you will meet.

You will first watch a race corrupt a counter in front of you, then
build the classic remedy: a thread-safe bounded buffer, the same
mutex-and-condition-variable pattern that sits inside every queue,
thread pool, and pipeline you will ever use.

## Part 1 — See the race: `submit/race.c`

`counter++` looks atomic. It is three machine steps — load, add,
store — and another thread can run between any two of them.

Edit [`submit/race.c`](submit/race.c): four threads, 200,000
increments each, one shared counter; `./race racy` increments bare,
`./race locked` increments under the mutex. Output contract:
`COUNT=<n>`, one line.

Then run the experiment:

```sh
gcc -Wall -Werror -O2 -pthread -o /tmp/race race.c
/tmp/race racy      # run it three times
/tmp/race racy
/tmp/race racy
/tmp/race locked
time /tmp/race racy ; time /tmp/race locked
```

Three racy runs give three *different* wrong answers — on our
reference VM, 10–12% of the increments simply vanish. The locked run
gives exactly 800000, every time, and costs about 10× the wall time.
Both facts go in your report.

While a run is alive, look at it with lab-1 eyes:

```sh
/tmp/race racy & ls /proc/$!/task/     # each thread is a directory
grep Threads: /proc/$!/status
```

Rule: `racy` mode must actually race — "fixing" the demo with atomics
is not passing it, and the checks look.

## Part 2 — The bounded buffer: `submit/array.h` + `submit/array.c`

### Interface and implementation

An interface says *what*; an implementation says *how*; the header/C
file split keeps them apart. A worked example — a (not thread-safe)
stack of ints:

```c
/* stack.h — the interface, and the struct behind it */
#pragma once
#define STACK_SIZE 10

typedef struct {
    int array[STACK_SIZE];
    int top;
} stack;

int  stack_init(stack *s);
int  stack_push(stack *s, int element);
int  stack_pop (stack *s, int *element);
void stack_free(stack *s);
```

```c
/* stack.c — the implementation */
#include "stack.h"
int stack_init(stack *s) { s->top = 0; return 0; }
int stack_push(stack *s, int element) {
    if (s->top >= STACK_SIZE) return -1;
    s->array[s->top++] = element;
    return 0;
}
int stack_pop(stack *s, int *element) {
    if (s->top < 1) return -1;
    *element = s->array[--s->top];
    return 0;
}
void stack_free(stack *s) { (void)s; }
```

Conventions to copy: `#pragma once`; every fallible function returns
an int status (0 = success); outputs come back through pointer
parameters.

### Your task

Now the real thing — same shape, three upgrades: it stores `char *`
payloads, it is safe under any number of threads, and where the stack
*fails* when full or empty, your array **blocks**:

```c
int  array_init(array *s);                  /* 0 on success */
int  array_put (array *s, char *hostname);  /* BLOCKS while full  */
int  array_get (array *s, char **hostname); /* BLOCKS while empty */
void array_free(array *s);
```

Complete [`submit/array.h`](submit/array.h) — you define the `array`
struct: storage for `ARRAY_SIZE` pointers, bookkeeping, one
`pthread_mutex_t`, and two `pthread_cond_t` (space available / items
available) — then implement [`submit/array.c`](submit/array.c).

Contract details:

- The array stores the *pointers* themselves; it never copies strings.
- Blocking means a condition-variable wait, not a retry loop: a
  waiting thread must burn ~zero CPU. One of the checks measures
  exactly that, camp-2 style.
- Remember why `pthread_cond_wait` lives inside a `while` loop, not an
  `if` — it matters the moment there are two consumers.

The checks compile an instructor test harness against your files
(`check/array-test.c` — read it, it is not secret) and drive them
through: round-trip, blocks-when-empty, blocks-when-full, and a
2-producer × 2-consumer × 500-item stress run where every item must
arrive exactly once. Every scenario is deadlock-guarded: a hang is a
FAIL, not a stuck grader.

## Stretch (ungraded) — a tiny multi-lookup

The legacy course built a whole threaded DNS resolver on this exact
interface. If you want the taste without the network: write
`multi-lookup.c` where one *requester* thread reads names from a file
and `array_put`s them, and two *resolver* threads `array_get` names,
look each up in a local table file (`name ip` lines — no network),
and append `name, ip` to a results file. Clean shutdown — resolvers
must terminate when the input is exhausted — is the interesting part:
where does "no more work is coming" live in your design? Nothing here
is graded; the buffer you already built is doing all the hard work.

## Check your work

From the repository root:

```sh
make check LAB=03-concurrency
```

Iterate live like the previous labs
(`SHARE=$PWD/03-concurrency/submit env/run.sh`, then compile and run
in `/share`). Everything compiles with `-Wall -Werror -pthread`.

## Submit

Commit and push `submit/race.c`, `submit/array.h`, `submit/array.c`,
and `submit/report.md` answering the four questions in it: what hides
inside `counter++`, threads vs processes in `/proc`, where the locked
run's time went, and why blocking beats polling.
