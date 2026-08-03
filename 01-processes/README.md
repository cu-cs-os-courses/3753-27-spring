# Basecamp 1: The Life and Times of a Process

In Basecamp 0 you learned to see the system. Now follow one process
through its whole life: birth (`fork`, `exec`), family (`PPid`, the
tree), states (R, S, Z), death and afterlife (exit status, zombies,
orphans, reaping).

Everything you observed in lab 0 pays off here: "every process is a
directory under `/proc`" becomes the family tree; `PID1_COMM` becomes
the adoptive parent of orphans; `/proc/self` becomes "who is asking"
when your script walks its own ancestry.

This is the first lab with C. The VM has `gcc` — you compile and run
**inside the guest**, so there is nothing to install on your laptop.

## Part 1 — The family tree (shell)

Every process's `/proc/<pid>/status` names its parent (`PPid:`). That
means the whole process tree is reconstructible from `/proc` alone —
so reconstruct a branch of it.

Edit [`submit/ptree.sh`](submit/ptree.sh): given a PID, print its
ancestry chain — one line for the PID, one for its parent, and so on,
ending with PID 1. The exact line format is in the file header. Read
only `/proc/<pid>/status`; no `ps`, no `pstree`.

Try it on interesting processes: your shell, `$$` from inside the VM
console, the innermost of `bash -c 'bash -c "sleep 60; :"; :' &` — and
look at which ancestors you did not expect to find.

## Part 2 — Birth: `fork` and `exec` (C)

`fork` copies a process; `exec` replaces one. They are two separate
ideas, and a shell is just a loop around both.

Edit [`submit/spawn.c`](submit/spawn.c): fork a child; the child
`exec`s the program named on the command line; the parent waits and
reports the child's fate on one line:

```
CHILD <pid> EXITED <status>
```

Contracts (the checks hold you to these exactly):

- the child's own output, if any, appears **before** the `EXITED` line
  (why is that guaranteed, given the parent `wait`s?);
- if `exec` fails, the child exits with status **127** — the shell's
  own convention, which you can verify: run `/nonexistent` in a shell
  and `echo $?`;
- `./spawn /bin/true` reports status 0, `./spawn /bin/false` status 1.

`man 2 wait` is your friend: `WIFEXITED`, `WEXITSTATUS`.

## Part 3 — Death and afterlife (C)

Edit [`submit/undead.c`](submit/undead.c). One program, two acts:

- **`./undead zombie`** — fork; the child exits with status 42
  immediately; the parent prints `CHILD <pid>`, then sleeps 10 seconds
  **without waiting**, then finally waits and prints
  `REAPED <pid> STATUS 42`. During those 10 seconds the child is dead
  but not gone — watch it from a second look at the system:

  ```sh
  ./undead zombie &
  cat /proc/<the printed pid>/stat    # third field: Z
  ```

  The checks do exactly this observation, automatically.

- **`./undead orphan`** — fork; the **child** prints `CHILD <pid>`
  (its own pid) and sleeps 10 seconds; the parent exits immediately.
  The child outlives its parent — so who is its parent now? Check
  `PPid:` in the child's `/proc/<pid>/status` while it sleeps.

**Buffering warning**: stdio buffers. When stdout is a file (which it
is, under the checker), a `printf` without `fflush(stdout)` may not
reach the file until the process exits — 10 seconds too late for
anyone observing. Flush before you sleep. This bites real systems
programmers weekly; better it bites you here first.

## Check your work

From the repository root:

```sh
make check LAB=01-processes
```

To iterate quickly, work inside a live VM (same flow as lab 0):

```sh
SHARE=$PWD/01-processes/submit env/run.sh
# inside the guest:
cd /share
gcc -Wall -Werror -o /tmp/spawn spawn.c && /tmp/spawn /bin/echo hi
bash ptree.sh $$
```

The checks compile your C with `-Wall -Werror` — warnings are errors,
here and in grading.

## Submit

Commit and push `submit/ptree.sh`, `submit/spawn.c`, `submit/undead.c`,
and `submit/report.md` answering the three questions already in it —
they ask what the code made observable: what a zombie is *for*, what
`exec` throws away, and who adopted your orphan.
