# Basecamp 5 — Report

## 1. Where the file position lives

Run your Step 2 session `S` on a new regular file, then run filetest
on the same file again with the single command `s 0 cur`. Using the
per-process open-file table of L20 §0.3 and the open and read steps of
L20 §1.1 and §1.2, explain why the second `r 10` printed `READ 0`, why
`s 0 end` printed `OFFSET 3`, and why the second run starts at
`OFFSET 0` although the first run ended at byte 3.

*(your answer)*

## 2. Why copy_to_user

In your driver, the user's buffer pointer arrives in `read`. Why can't
you just `memcpy` into it? Connect your answer to the address spaces
of Lab04. And what happens (to your driver, and to the process) if
the user hands you a garbage pointer?

*(your answer)*

## 3. Where the paths diverge

Trace one `read` on `/tmp/plain` and one `read` on
`/dev/simple_char_driver` through the models of L20 §1.2 and L17 §3.4
and §4.1. At which step do the two paths part, and what does the
kernel find in the file's inode that sends the second `read` to your
`scd_read`? Support your answer with `ls -l` of both files and the
line for 511 in `/proc/devices`.

*(your answer)*
