# Basecamp 1 — Report

## 1. The zombie's purpose

In `undead zombie`, the child is dead for 10 seconds but still has an
entry in `/proc`. What is the kernel keeping alive, and for whom? What
single line of parent code makes it disappear?

*(your answer)*

## 2. What exec replaces

Run `/tmp/spawn /bin/sleep 20` in the background, read
`/proc/<pid>/status` of the sleeping child from your shell, and compare
its `Name`, `Pid` and `PPid` lines with the `CHILD` line that spawn
prints when the sleep ends. Using L03 §1.4, say what exec replaced and
which values it kept, and why.

*(your answer)*

## 3. The adoption

Who adopted your orphan, and which two observations from your own run
show it? According to L03 §2.2, would the adopter change if PID 1 ran a
program other than systemd?

*(your answer)*
