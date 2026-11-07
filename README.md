# CSCI 3753 Labs: OS Basecamp


The six labs (Basecamps) of CSCI 3753 Operating Systems at the University
of Colorado Boulder. Each lab's specification is its walkthrough on the
course site, <https://cu-cs-os-courses.github.io/base-camp-academy/>.

## Setup

Every lab runs in a local VM on your laptop (macOS or Linux), built by
[`env/`](env/README.md).

```sh
cd env
make setup && make images && make smoke
```

## Labs

| Camp | Topic |
|---|---|
| [`labs/00-getting-started/`](labs/00-getting-started/) | Basecamp 0: Learning to See a Running System |
| [`labs/01-processes/`](labs/01-processes/) | Basecamp 1: The Life and Times of a Process |
| [`labs/02-scheduling/`](labs/02-scheduling/) | Basecamp 2: Sharing the CPU |
| [`labs/03-concurrency/`](labs/03-concurrency/) | Basecamp 3: The Trouble with Threads |
| [`labs/04-virtual-memory/`](labs/04-virtual-memory/) | Basecamp 4: Pages, Faults, and the Art of Eviction |
| [`labs/05-storage-and-io/`](labs/05-storage-and-io/) | Basecamp 5: Everything Is a File |

## Reporting a bug

If you find a bug in a lab, a check, or the VM environment, open an issue
in this repository at
<https://github.com/cu-cs-os-courses/3753-27-spring/issues>. Say which lab
and step, what you ran, what you expected, and what you saw. Paste the
exact command and its output.

This repository is public. Therefore, never paste your own solution code
into an issue. Questions about your own work go to office hours or
recitation.
