# Basecamp 2 — Report

## 1. The geometry of nice

Your measured `fairshare.sh 0 10 15` ratio, vs. the weight-table
prediction 1024/110 ≈ 9.3: how close did you land? The table makes each
nice level a factor of ~1.25 — why geometric rather than linear? (What
would "nice +10" mean under a linear table if the system already had
100 runnable tasks?)

*(your answer, with your measured number)*

## 2. CFS vs EEVDF, against your own data

Lecture taught CFS; your 6.6 kernel runs EEVDF inside the same fair
class. Which things you measured in this lab are identical under both —
cite `se.load.weight` and `se.vruntime` from `/proc/<pid>/sched` — and
what did EEVDF actually replace? Why does your measured 0-vs-10 ratio
not depend on which of the two is running?

*(your answer)*

## 3. The safety valve

The FIFO-50 spinner did not get 100%: the normal task kept a small,
round share. Which `/proc/sys/kernel/` setting is responsible (name it,
quote its value), and why does the kernel refuse to hand real-time
tasks the whole CPU?

*(your answer)*
