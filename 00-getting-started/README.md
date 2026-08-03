# Basecamp 0: Learning to See a Running System

Welcome to CSCI 3753. Before the climb starts, you set up basecamp: get the
course VM running on your own machine, and take your first direct look at a
live operating system through the interface the kernel itself provides —
the `/proc` filesystem.

There is no VDI, no shared server, and nothing to wait for: the entire
environment builds and runs on your laptop.

**What you need before starting:**

- a laptop running macOS (Apple Silicon or Intel) or Linux, with about
  **20 GB of free disk** (kernel build cache + a 4 GB disk image + Docker
  images) and 8 GB of RAM;
- on macOS: [Homebrew](https://brew.sh) installed (`make setup` uses it to
  install QEMU and Docker);
- a [GitHub](https://github.com) account (Part 0).

## Part 0 — Get your repository

Accept the **GitHub Classroom invitation link posted on Canvas**. It
creates a private repository owned by you — your personal copy of the
course tree — and that repository is what the TAs grade. Clone it:

```sh
git clone <the URL shown on your repository's green "Code" button>
cd <your-repo>
```

Everything below happens inside this clone. Do **not** clone the course
repository itself — work you push anywhere other than your Classroom
repository is invisible to grading.


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

Inside the VM, explore `/proc` — the kernel's window onto itself. Start
with the map, then look around:

```sh
ls /proc                     # the whole window: files, and one directory per process
cat /proc/version
ls /proc/1/
cat /proc/meminfo | head
grep . /proc/sys/kernel/*    # everything here greps like an ordinary file
```

Then edit [`submit/observe.sh`](submit/observe.sh) so it reports eight facts
about the running system, reading **only** `/proc` (no `uname`, no `nproc`
— find where the kernel exposes these values directly). The eight facts are
chosen to make you look at four different faces of `/proc`: system-wide
constants (kernel release, CPUs, memory), the boot command line (compare it
with `env/run.sh`), per-process views (`/proc/<pid>/`, and `/proc/self` —
which answers "who is asking?"), and live counters that change every time
you look (`/proc/stat`).

## Check your work

From the repository root:

```sh
make check LAB=00-getting-started
```

This boots the VM headless, runs your `observe.sh` inside it, and prints
PASS/FAIL per item. The TAs grade by running **exactly the same checks** on
your submission — if it passes locally, it passes grading.

### If a check fails

The PASS/FAIL lines name the check, not what your script printed — so go
look at the output yourself, in a live VM. From the repository root:

```sh
SHARE=$PWD/00-getting-started/submit env/run.sh
```

Your `submit/` directory appears inside the guest at `/share`. Run your
script there and compare its output against the format in the file header:

```sh
bash /share/observe.sh
```

Edit on the host, re-run in the guest — the share is live, no reboot
needed — then confirm with `make check` when the output looks right.

A failing `make check` also prints `(artifacts kept at …)`. That directory
holds `result.txt` (the raw check output) and `console.log` (the VM's boot
log — the place to look if the VM never came up at all).

## Submit

Commit and push `submit/observe.sh`, plus a short `submit/report.md`
answering:

1. Run `observe.sh` twice. Which values changed, and why? (`SELF_PID`
   deserves a sentence of its own: what exactly is `/proc/self`?)
2. `/proc/meminfo` reports both `MemFree` and `MemAvailable`, and they
   disagree. What is the difference, and which one should a program that
   wants to know "can I allocate this much?" look at?
3. One thing you found in `/proc` that surprised you.
