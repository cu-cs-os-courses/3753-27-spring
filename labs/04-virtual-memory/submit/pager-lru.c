/* Basecamp 4, Part 2 — the pager.
 *
 * Implement LRU eviction in pageit(). The simulator calls this every
 * tick; the API and the pentry struct are documented in
 * check/sim/simulator.h and the Lab04 walkthrough. Note the static variables —
 * they preserve your pager's state between calls.
 *
 * Verify locally with:  make check LAB=04-virtual-memory
 */
#include "simulator.h"
#include <stdio.h>
#include <stdlib.h>

void pageit(Pentry q[MAXPROCESSES]) {

  // static variables
  static int initialized = 0;
  static int tick = 1; // artificial time
  static int timestamps[MAXPROCESSES][MAXPROCPAGES];

  // local variables
  int proc;
  int page;

  // initialise timestamp array on first run
  if (!initialized) {
    for (proc = 0; proc < MAXPROCESSES; proc++) {
      for (page = 0; page < MAXPROCPAGES; page++) {
        timestamps[proc][page] = tick - 1; // i.e. 0: "never used yet"
      }
    }
    initialized = 1;
  }

  // TODO: implement LRU paging. (The fprintf below reads a timestamp
  // only so the unfilled skeleton compiles under -Werror — delete
  // these three lines when you start.)
  fprintf(stderr, "pager-lru not yet implemented (timestamps[0][0]=%d)\n",
          timestamps[0][0]);
  exit(EXIT_FAILURE);

  // advance time for next pageit() iteration
  tick++;
}
