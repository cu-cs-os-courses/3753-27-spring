/* Basecamp 5, Part 1 — the user side: a file-I/O REPL over raw
 * syscalls (open/read/write/lseek/close; stdio only for the command
 * loop itself).
 *
 * Usage: filetest <file>
 *
 * Open <file> read-write (create it if absent, mode 0644); if the open
 * fails: perror and exit 255 — the shell convention for "died badly",
 * which the checks assert. Then read commands from stdin, one per
 * line:
 *
 *   r <n>              read up to n bytes at the current offset
 *                      -> print exactly:  READ <k> <data>
 *                         (k = bytes actually read, data = those bytes)
 *   w <text>           write <text> (the rest of the line) at the
 *                      current offset
 *                      -> print exactly:  WROTE <k>
 *   s <off> <whence>   lseek; whence is set|cur|end
 *                      -> print exactly:  OFFSET <newoff>
 *   q  (or EOF)        close and exit 0
 *
 * Note there is no "tell" command: `s 0 cur` IS tell. Worth a moment's
 * thought about why.
 *
 * The command loop and parsing are given below — your work is the four
 * syscall actions.
 *
 * Verify locally with:  make check LAB=05-storage-and-io
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s <file>\n", argv[0]);
        return 2;
    }

    int fd = -1;
    /* TODO: open argv[1] read-write, creating with mode 0644 if
     * absent. On failure: perror("open") and return 255. */

    char line[4096];
    while (fgets(line, sizeof line, stdin)) {
        line[strcspn(line, "\n")] = '\0';

        if (strcmp(line, "q") == 0) {
            break;
        } else if (strncmp(line, "r ", 2) == 0) {
            long n = atol(line + 2);
            /* TODO: read up to n bytes from fd into a buffer; print
             * "READ <k> <data>\n" where k is read()'s return value and
             * data is exactly those k bytes (hint: printf "%.*s"). */
            (void)n;
        } else if (strncmp(line, "w ", 2) == 0) {
            const char *text = line + 2;
            /* TODO: write text (strlen bytes, no newline) to fd; print
             * "WROTE <k>\n" where k is write()'s return value. */
            (void)text;
        } else if (strncmp(line, "s ", 2) == 0) {
            long off;
            char wh[8];
            if (sscanf(line + 2, "%ld %7s", &off, wh) == 2) {
                /* TODO: map set|cur|end to SEEK_SET|SEEK_CUR|SEEK_END,
                 * lseek, print "OFFSET <newoff>\n". Unknown whence:
                 * print "ERR\n". */
            } else {
                printf("ERR\n");
            }
        } else {
            printf("ERR\n");
        }
        fflush(stdout);
    }

    close(fd);
    return 0;
}
