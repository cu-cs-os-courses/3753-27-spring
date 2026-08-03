# Basecamp 2: Sharing the CPU

Lab 1 followed one process through its life. But your VM has 2 CPUs and
dozens of processes — someone is deciding who runs next, every few
milliseconds, on every core. This lab makes that someone visible, then
measures its policies.

A note before you start: lecture teaches CFS. Your 6.6 kernel runs
CFS's successor **EEVDF** inside the same fair scheduling class.
Everything you measure in this lab — the nice weight table, vruntime
accounting, CPU shares — is identical under both; what EEVDF changed is
how the next task is picked. Report question 2 asks you to make exactly
this distinction, with your own data.

## Part 1 — Make load, see preemption

Edit [`submit/spin.c`](submit/spin.c): an infinite CPU-bound loop.
That's the whole program — the scheduler does the interesting part.

Compile it in the VM and run two instances **pinned to the same CPU**:

```sh
gcc -Wall -Werror -O2 -o /tmp/spin spin.c
taskset -c 0 /tmp/spin &
taskset -c 0 /tmp/spin &
```

Now observe them from the outside, with lab-1 skills:

```sh
cat /proc/<pid>/stat        # field 3: both R — both runnable, one CPU
grep nr_involuntary /proc/<pid>/sched   # climbing: forced off the CPU
grep se.load.weight /proc/<pid>/sched   # the weight behind "fairness"
kill %1 %2
```

Two processes, one CPU, both in state R, neither starving: you are
watching timeslicing.

## Part 2 — The meaning of nice

`nice` is not a polite suggestion — it indexes a weight table, and the
scheduler divides the CPU in proportion to weight. Measure it.

Edit [`submit/fairshare.sh`](submit/fairshare.sh):
`fairshare.sh <niceA> <niceB> <seconds>` runs two copies of your spin
binary on CPU 0 at the two nice levels, measures each one's utime
growth over the window (field 14 of `/proc/<pid>/stat`), and prints
exactly one line — the format contract is in the file header. Read only
`/proc`; no `top`, no `ps`.

Then run your instrument:

```sh
bash fairshare.sh 0 0 10     # equal weights — expect RATIO near 1
bash fairshare.sh 0 10 15    # ten nice levels apart — expect... what?
```

Before trusting your number, predict it: the weight for nice 0 is 1024,
for nice 10 it is 110. Each nice level is a factor of ~1.25 — geometric,
not linear. Your measurement should land near 1024/110 ≈ 9.3.

## Part 3 — Policy beats weight

Weights share; **policies rank**. A `SCHED_FIFO` task outranks every
fair-class task, categorically:

```sh
taskset -c 0 /tmp/spin &                 # a normal citizen
taskset -c 0 chrt -f 50 /tmp/spin &      # a real-time task, priority 50
```

Predict: what share does the normal spinner get? Now measure it (your
fairshare sampling technique works here too — sample the two utimes by
hand). The answer is not 0% — the normal spinner clings to a small,
suspiciously round share. Find the setting responsible, somewhere under
`/proc/sys/kernel/`, and explain in your report why the kernel refuses
to give real-time tasks the last few percent. Then clean up your
spinners — a stray FIFO-50 spinner makes a VM miserable.

## Look deeper (ungraded)

The kernel can narrate every context switch it makes. Watch your two
spinners take turns, timestamped at microsecond resolution:

```sh
taskset -c 0 /tmp/spin &  taskset -c 0 /tmp/spin &
trace-cmd record -e sched_switch -- sleep 2
trace-cmd report | grep spin | head -20
kill %1 %2
```

Every line is one decision by the scheduler you have been measuring all
lab. (`/sys/kernel/tracing/` is the raw interface underneath — the
grad course, KernelLens, lives down there.)

## Check your work

From the repository root:

```sh
make check LAB=02-scheduling
```

To iterate quickly, use the live-VM flow from labs 0–1
(`SHARE=$PWD/02-scheduling/submit env/run.sh`, then work in `/share`).
The checks compile your C with `-Wall -Werror`, verify your spinner
actually pegs a CPU, and re-run both of your fairshare experiments with
banded tolerances — a correct implementation passes with margin.

## Submit

Commit and push `submit/spin.c`, `submit/fairshare.sh`, and
`submit/report.md` answering the three questions in it: the geometry of
nice, CFS vs EEVDF against your own data, and the real-time safety
valve.
