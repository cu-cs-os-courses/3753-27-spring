# CSCI 3753 Labs: OS Basecamp


This repository holds the six labs (Basecamps) of CSCI 3753 Operating
Systems at the University of Colorado Boulder.

## The environment

Every lab runs in a local VM on your own laptop (macOS or Linux): QEMU, a
pinned Linux kernel, and a Debian root file system, built by
[`env/`](env/README.md).

```sh
cd env
make setup && make images && make smoke
```

## The route

| Camp | Topic |
|---|---|
| [`labs/00-getting-started/`](labs/00-getting-started/) | Basecamp 0: Learning to See a Running System |
| [`labs/01-processes/`](labs/01-processes/) | Basecamp 1: The Life and Times of a Process |
| [`labs/02-scheduling/`](labs/02-scheduling/) | Basecamp 2: Sharing the CPU |
| [`labs/03-concurrency/`](labs/03-concurrency/) | Basecamp 3: The Trouble with Threads |
| [`labs/04-virtual-memory/`](labs/04-virtual-memory/) | Basecamp 4: Pages, Faults, and the Art of Eviction |
| [`labs/05-storage-and-io/`](labs/05-storage-and-io/) | Basecamp 5: Everything Is a File |

Each lab's specification is its walkthrough page on the course site,
<https://cu-cs-os-courses.github.io/base-camp-academy/>, together with the
header comments of its `submit/` files. Each lab directory contains:

- `README.md` — the link to the lab's walkthrough
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

- `env/` — the VM environment (origin and license: `env/UPSTREAM`)
- `scripts/check-lab.sh` — harness: boot headless, run a lab's checks via
  the autorun channel, report PASS/FAIL
- `labs/NN-*/` — the labs
