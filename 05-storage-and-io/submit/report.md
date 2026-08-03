# Basecamp 5 — Report

## 1. Who owns the offset?

Open the same regular file in two terminals with your filetest and
interleave `s`/`r` commands. Does each open get its own offset, or do
they share one? Report the experiment and its result — then say where
the offset actually lives (fd? file description? inode? process?).

*(your answer)*

## 2. Why copy_to_user

In your driver, the user's buffer pointer arrives in `read`. Why can't
you just `memcpy` into it — connect to camp 4's address spaces. And
what happens (to your driver, and to the process) if the user hands
you a garbage pointer?

*(your answer)*

## 3. The buffer's afterlife

What happens to your device buffer's contents between `rmmod` and the
next `insmod`, and why? What would `cat /dev/simple_char_driver` have
shown before the first write if you had used `kmalloc` instead of
`kzalloc` — and why is that a (mild) security story?

*(your answer)*

## 4. Where the paths diverge

Your filetest drove an ext4 file and your driver with identical
commands and identical results. Trace one `read` from the syscall
down: where exactly does the kernel decide to call *your* `scd_read`
instead of the filesystem's read path — what data structure makes the
dispatch?

*(your answer)*
