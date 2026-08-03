/* Basecamp 1, Part 2 — birth: fork and exec.
 *
 * Usage: spawn <program> [args...]
 *
 * Fork a child; the child execs <program> with the given args; the
 * parent waits and prints exactly one line:
 *
 *   CHILD <pid> EXITED <status>
 *
 * If exec fails, the child must exit with status 127 (the shell's own
 * convention for "command not found").
 *
 * Verify locally with:  make check LAB=01-processes
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "usage: %s <program> [args...]\n", argv[0]);
        return 2;
    }

    /* TODO 1: create the child with fork(). On failure: perror("fork")
     * and return 1. */

    /* TODO 2 — child only: replace yourself with argv[1], passing
     * &argv[1] as its argument vector (see execv(3)). If exec returns
     * at all, it failed: _exit(127). */

    /* TODO 3 — parent only: wait for the child (waitpid). If it exited
     * normally, print the CHILD line above, using WEXITSTATUS to decode
     * the status. Return 0. */

    return 0;
}
