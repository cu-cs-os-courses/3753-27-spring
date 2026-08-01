# Basecamp 0: Learning to See a Running System

Welcome to CSCI 3753. Before the climb starts, you set up basecamp: get the
course VM running on your own machine, and take your first direct look at a
live operating system through the interface the kernel itself provides —
the `/proc` filesystem.

There is no VDI, no shared server, and nothing to wait for: the entire
environment builds and runs on your laptop.

## Part 1 — Set up the environment

Follow [`env/README.md`](../env/README.md):

```sh
cd env
make setup      # one-time host setup (macOS; Linux: scripts/host-setup-ubuntu.sh)
make images     # build the pinned kernel + rootfs (first run: ~30-60 min)
make smoke      # verify the environment works
make run        # boot an interactive VM (root auto-login; exit: Ctrl-a x)
```

## Part 2 — Observe the system

Inside the VM, explore `/proc` — the kernel's window onto itself:

```sh
cat /proc/version
ls /proc/1/
cat /proc/meminfo | head
```

Then edit [`submit/observe.sh`](submit/observe.sh) so it reports four facts
about the running system, reading **only** `/proc` (no `uname`, no `nproc`
— find where the kernel exposes these values directly).

## Check your work

From the repository root:

```sh
make check LAB=00-getting-started
```

This boots the VM headless, runs your `observe.sh` inside it, and prints
PASS/FAIL per item. The TAs grade by running **exactly the same checks** on
your submission — if it passes locally, it passes grading.

## Submit

Commit and push `submit/observe.sh`, plus a short `submit/report.md`:
what you learned, what was confusing, and one thing you found in `/proc`
that surprised you.
