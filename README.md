# OS Basecamp


Foundational labs for CSCI 3753 (Operating Systems, undergraduate) at CU
Boulder. Learn to observe, model, and reason about running systems — the
groundwork you need before any serious climb, and before you can direct an
LLM at systems problems with judgment instead of hope.

Basecamp prepares students for the climb.
[kernel-lens](https://github.com/cu-cs-os-courses/kernel-lens) lets them
inspect the terrain.

## The environment

Every lab runs in a local, reproducible VM: QEMU + a pinned Linux kernel +
a Debian rootfs, built by [`env/`](env/README.md) on your own laptop
(macOS or Linux). No VDI, no shared servers, no waiting for IT.

```sh
cd env
make setup && make images && make smoke
```

Because the environment is pinned, behavior is identical on every machine
— yours, your classmates', and the graders'.

## The route

| Camp | Topic |
|---|---|
| [`labs/00-getting-started/`](labs/00-getting-started/) | Basecamp 0: Learning to See a Running System |
| [`labs/01-processes/`](labs/01-processes/) | Basecamp 1: The Life and Times of a Process |
| [`labs/02-scheduling/`](labs/02-scheduling/) | Basecamp 2: Sharing the CPU |
| [`labs/03-concurrency/`](labs/03-concurrency/) | Basecamp 3: The Trouble with Threads |
| [`labs/04-virtual-memory/`](labs/04-virtual-memory/) | Basecamp 4: Pages, Faults, and the Art of Eviction |
| [`labs/05-storage-and-io/`](labs/05-storage-and-io/) | Basecamp 5: Everything Is a File |

Each lab directory contains:

- `README.md` — the write-up
- `submit/` — the files you edit and push; this is your submission
- `check/` — the checks, which run inside the VM

## Checking your work

```sh
make check LAB=00-getting-started
```

This boots the VM headless, runs the lab's checks against your `submit/`
directory inside it, and prints PASS/FAIL per item. Grading re-runs the
**same checks from the instructor's copy** against your `submit/` — so a
local pass is a grading pass, and editing `check/` in your own repo does
nothing.

## Repository layout

- `env/` — reference VM environment, vendored from
  [kernel-lens](https://github.com/cu-cs-os-courses/kernel-lens)
  (see `env/UPSTREAM`); Apache-2.0
- `scripts/check-lab.sh` — harness: boot headless, run a lab's checks via
  the autorun channel, report PASS/FAIL
- `labs/NN-*/` — the labs
