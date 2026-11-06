/* Basecamp 1, Part 3 — death and afterlife.
 *
 * Usage: undead zombie | undead orphan
 *
 * zombie:  fork. The child exits with status 42 immediately. The parent
 *          prints "CHILD <pid>" (the child's pid), flushes stdout,
 *          sleeps 10 seconds WITHOUT waiting — the child is a zombie
 *          for all of them — then waits and prints
 *          "REAPED <pid> STATUS <status>" with the status decoded from
 *          wait (it had better be 42).
 *
 * orphan:  fork. The CHILD prints "CHILD <pid>" (its own pid — the
 *          parent won't live long enough to do it), flushes stdout, and
 *          sleeps 10 seconds. The parent exits immediately, without
 *          waiting. While the child sleeps, its PPid: tells you who
 *          adopted it.
 *
 * Remember: flush stdout before any sleep — see the buffering warning
 * in the Lab01 walkthrough.
 *
 * Verify locally with:  make check LAB=01-processes
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s zombie|orphan\n", argv[0]);
        return 2;
    }

    if (strcmp(argv[1], "zombie") == 0) {
        /* TODO: implement the zombie act described above. */

    } else if (strcmp(argv[1], "orphan") == 0) {
        /* TODO: implement the orphan act described above. */

    } else {
        fprintf(stderr, "usage: %s zombie|orphan\n", argv[0]);
        return 2;
    }
    return 0;
}
