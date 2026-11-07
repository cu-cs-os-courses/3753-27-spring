# Basecamp 4 — Report

## 1. The lie of malloc

Paste your touch.c numbers. `malloc(64 MiB)` returned success, so why
was `RSS_KB_BEFORE` so small? Go through the six steps of a page fault
in Lecture 15 and say what each of your ~16,000 page faults did and
which step it did not need. If the kernel later evicted one of these
pages and your program touched it again, where would its contents come
from?

*(your answer)*

## 2. The 75×

pager-basic scores ~15, and your LRU should score well under 1.28. Explain
where the orders of magnitude come from, and how you chose your eviction
victim.

*(your answer)*

## 3. Where LRU is exactly wrong

LRU bets that the recent past predicts the near future. Using one of
the five simulated program structures (or a pattern of your own
construction), show an access pattern where LRU's bet loses, namely where
the page it evicts is precisely the one needed next.

*(your answer)*
