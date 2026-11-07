# Basecamp 3 — Report

## 1. Inside `counter++`

Your three racy COUNTs (paste them). Why do they differ from run to
run? Name the three machine steps hiding inside `counter++` and show,
with a two-thread interleaving, exactly where an increment gets lost.

*(your answer)*

## 2. Threads in /proc

What did `ls /proc/<pid>/task/` and `Threads:` show while race ran?
In Lab01 terms, what do the four workers share that four *processes*
would not, and what does each still own privately?

*(your answer)*

## 3. Blocking beats polling

Why must `array_put`/`array_get` wait on a condition variable instead
of looping until the state changes? One of the checks measured the
CPU time your program used while its thread waited. Connect that
number to your answer. And why does `pthread_cond_wait` sit inside a
`while`, not an `if`?

*(your answer)*
