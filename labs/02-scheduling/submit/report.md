# Basecamp 2 — Report

## 1. The geometry of nice

Compare your measured `fairshare.sh 0 10 15` ratio with the prediction
1024/110 ≈ 9.3 from the weight table in L07 §3.4. How close did you land?
Then predict, from the same table, the ratios for `fairshare.sh 0 5 15`
and `fairshare.sh 10 15 15`, and measure both. Why are those two ratios
nearly equal? What would a table that subtracts the same amount of weight
at every nice step predict for them instead?

*(your answer, with your measured numbers)*

## 2. vruntime and the measured share

Start a nice 0 spinner and a nice 10 spinner on CPU 0 as in Step 2. Read
`se.vruntime` from `/proc/<pid>/sched` and utime from `/proc/<pid>/stat`
for both, wait 10 seconds, and read them again. Quote how much each value
grew. One spinner ran about nine times as long as the other, yet the two
vruntimes grew by about the same amount. Use the formula in L07 §3.4 to
show why, and explain how the rule of running the task with the smallest
vruntime produces the ratio your `fairshare.sh` measured.

*(your answer, with your measured numbers)*

## 3. Policy beats weight

In Step 5 a SCHED_FIFO spinner and a normal spinner shared CPU 0. Quote
the utime growth of each and the normal spinner's share. Use L07 §4.3 to
explain that share. Would starting the normal spinner at nice −20 have
changed it? Why or why not? Your shell kept working the whole time. Use
L07 §5.1 and §5.2 to explain why.

*(your answer, with your measured numbers)*
