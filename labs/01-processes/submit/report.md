# Basecamp 1 — Report

## 1. The zombie's purpose

In `undead zombie`, the child is dead for 10 seconds but still has an
entry in `/proc`. What is the kernel keeping alive, and for whom? What
single line of parent code makes it disappear?

*(your answer)*

## 2. What exec throws away

Between `fork` and `exec` in `spawn.c`, the child briefly was a copy of
its parent. What did `exec` replace, and name two things that survive
exec. (`/proc/self/cmdline` before and after is a good probe.)

*(your answer)*

## 3. The adoption

Who adopted your orphan, and how did you verify it? Would the answer be
the same on a system where PID 1 is not systemd?

*(your answer)*
