# Basecamp 4: Pages, Faults, and the Art of Eviction

An address space is a promise, not an allocation. `malloc` hands you
64 MiB of addresses and the kernel hands you — nothing, yet. Pages
materialize on first touch, one page fault at a time, and when
physical memory runs short, someone has to decide which page gets
evicted. In this lab you first *watch* the real kernel keep its
promise lazily, then step into the page-fault handler's shoes in a
simulator where the eviction policy is yours to write.

## Part 1 — Watch pages materialize: `submit/touch.c`

Edit [`submit/touch.c`](submit/touch.c): malloc 64 MiB, read your own
`VmRSS` (from `/proc/self/status`) and minor-fault count (field 10 of
`/proc/self/stat` — lab-0 territory), touch one byte in every
4096-byte page, read both again. The output contract is in the file
header.

Compile and run it in the VM. Two numbers to sit with: RSS grows by
~64 MiB only *at touch time*, and the kernel serviced ~16,000 minor
faults to make it happen — one per page, each one materializing a
physical page you were promised but never given.

One wrinkle you will hit: run it as-is and you'll see only ~500
faults, not 16,384 — yet RSS still grew the full 64 MiB. That is
**transparent huge pages**: the kernel noticed your big sequential
region and backed it with 2 MiB pages, 512× fewer faults for the same
memory. See for yourself, then turn it off for the clean
one-fault-per-page measurement (the checker does the same):

```sh
cat  /sys/kernel/mm/transparent_hugepage/enabled   # [always] ...
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```

Both numbers are true answers to "what did the kernel do" — worth a
sentence in your report.

## Part 2 — The pager: `submit/pager-lru.c`

Now switch roles. A paging simulator (by Dr. Alva Couch, Tufts —
vendored in [`check/sim/`](check/sim/), source open like every check
in this course) runs 20 concurrent processes over 400 virtual pages
with only **100 physical frames**, and calls *your* `pageit()` every
tick — you are the page-fault handler.

The economics are brutal by design: 1 tick per instruction, **100
ticks** per swap-in or swap-out. Your score is the ratio of blocked
ticks to compute ticks — time wasted waiting on paging vs. useful
work.

### The interface (`check/sim/simulator.h`)

`pageit(Pentry q[MAXPROCESSES])` receives, per process:

- `active` — 1 running, 0 exited
- `pc` — program counter; the page it needs is `pc / PAGESIZE`
- `npages` — pages in the process's space (20 while active)
- `pages[]` — the page map: 1 swapped in, 0 not (out, going out, or
  coming in — the map alone doesn't distinguish; if your policy needs
  to know about in-flight operations, track them yourself)

You act through `pagein(proc, page)` and `pageout(proc, page)`. Both
return 1 if the operation starts, is already underway, or is already
done; 0 if it can't start (no free frame, or the page is mid-swap the
other way). An operation completes 100 ticks after it starts.

Key constants (grading uses these defaults): 20 processes × 20 virtual
pages, 100 physical frames, `PAGESIZE` 128, `PAGEWAIT` 100.

### The programs being paged

The simulator's 40 processes are drawn randomly from five known
program shapes:

```
1: loop w/ branch      2: one loop       3: doubly nested
   for 10 30              for 20 50         for 10 20
     run 500                run 1129          run 1166
     if .4                end                 for 10 20
       run 900            exit                  run 516
     else                                     end
       run 131         4: linear            end
     endif                run 1911          exit
   end                    exit
   exit                5: probabilistic backward branch
                          for 10 20
                            label: run 500
                            if .5 goto label
                          end
                          exit
```

Which branches fire and how many iterations run depend on the seed —
you can never predict an execution, only its probabilistic shape. The
shapes matter mostly for the stretch below; for LRU all you need to
believe is that the recent past predicts the near future *most* of
the time.

### Your task

`pager-basic.c` (provided, readable) runs one process at a time and
never evicts. Build and run it for a baseline:

```sh
gcc -Wall -Werror -O2 -Icheck/sim -o /tmp/test-basic \
    check/sim/simulator.c check/sim/programs.c check/sim/pager-basic.c
/tmp/test-basic -seed 1        # ratio blocked/compute=... despair
```

On our reference VM it scores **~15**. Your job: implement LRU
eviction in [`submit/pager-lru.c`](submit/pager-lru.c) (the skeleton's
static timestamp array is a strong hint) and beat it by orders of
magnitude. Decisions you own: local LRU (each process evicts its own
pages — consider reserving frames per process) or global; how to
track recency; what to do while a page is in flight.

The simulator is seeded and exactly deterministic: same seed, same
ratio, every time. `-help` lists the flags; `-csv` dumps a trace of
every block/unblock if you want to see your policy think.

### Self-assessment

The legacy course graded this ratio, averaged over several seeds:

| avg ratio | verdict |
|---|---|
| ≥ 5.12 | worse than useless |
| 2.56 – 5.12 | barely paging |
| 1.28 – 2.56 | getting there |
| 0.64 – 1.28 | **the checks' passing bar** |
| 0.32 – 0.64 | good LRU |
| < 0.32 | excellent — reference territory |

`make check` requires the average over seeds 1–3 to be **below 1.28**;
an honest LRU clears that several times over.

## Stretch (ungraded) — predict the future

LRU only reacts. But you *know* the five program shapes — a
doubly-nested loop will come back; a straight line never will. Copy
your pager to `pager-predict.c` and prefetch: track each process's
branch behavior, and during idle paging capacity, page in what the
structure says comes next. Build it the same way you built `test-lru`
and let the simulator score it. Getting meaningfully under a good LRU
is genuinely hard — which is the point.

## Check your work

From the repository root:

```sh
make check LAB=04-virtual-memory
```

Iterate live as always (`SHARE=$PWD/labs/04-virtual-memory/submit
env/run.sh` — plus `SHARE` gives you the whole lab dir if you mount
the lab root instead). The checks: touch.c's numbers, your pager
compiling clean, running to completion, **bit-identical determinism**
across two same-seed runs, beating the baseline, and the 1.28 bar.

## Submit

Commit and push `submit/touch.c`, `submit/pager-lru.c`, and
`submit/report.md` answering its four questions: the lie of malloc,
where your 75× came from, whether 100:1 is honest, and a pattern where
LRU is exactly wrong.
