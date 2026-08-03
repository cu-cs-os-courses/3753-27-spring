# Basecamp 4 — Report

## 1. The lie of malloc

Paste your touch.c numbers. `malloc(64 MiB)` returned success — so why
was `RSS_KB_BEFORE` so small? What did each of your ~16,000 minor
faults actually do? And what would have made them *major* faults
instead?

*(your answer)*

## 2. The 75×

pager-basic scores ~15; your LRU should score well under 1.28. Explain
where the orders of magnitude come from, how you chose your eviction
victim, and whether your LRU is local (per process) or global — and
why.

*(your answer)*

## 3. Is 100:1 honest?

The simulator charges 100 ticks per swap against 1 tick per
instruction. A real SSD read costs ~100 µs while an instruction costs
~1 ns. Is the simulator's ratio generous or cruel compared to reality,
and what does the real number imply about how expensive a page fault
"feels" to a running process?

*(your answer)*

## 4. Where LRU is exactly wrong

LRU bets that the recent past predicts the near future. Using one of
the five simulated program structures (or a pattern of your own
construction), show an access pattern where LRU's bet loses — where
the page it evicts is precisely the one needed next.

*(your answer)*
