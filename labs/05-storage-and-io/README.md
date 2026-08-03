# Basecamp 5: Everything Is a File

The claim behind Unix I/O is audacious: files, terminals, pipes,
devices — one interface. `open`, `read`, `write`, `lseek`, `close`.
In this final camp you stand on both sides of that interface in a
single lab: first wielding those five verbs as a user, then
*implementing* them as the kernel-side driver they dispatch into. The
proof at the end: your own Part-1 tool drives your own Part-2 device,
unmodified, and cannot tell it from a regular file.

This is the course's only kernel-code lab, and it needs one extra
thing on your host: **Docker must be running** when you `make check`
(the module is compiled against the pinned kernel tree in the same
container that built your VM — a kernel module is built *for one exact
kernel*, and the guest has no kernel tree of its own).

## Part 1 — The user side: `submit/filetest.c`

A file-I/O REPL over raw syscalls. `./filetest <file>` opens the file
read-write (creating it if needed) and takes commands from stdin, one
per line:

| command | action | prints |
|---|---|---|
| `r <n>` | read up to n bytes at the offset | `READ <k> <data>` |
| `w <text>` | write text at the offset | `WROTE <k>` |
| `s <off> <whence>` | lseek (`set`/`cur`/`end`) | `OFFSET <newoff>` |
| `q` / EOF | close, exit 0 | — |

Bad filename: `perror` and **exit 255**. There is deliberately no
"tell" command — `s 0 cur` *is* tell, and understanding why is half
the point of `lseek`.

The skeleton gives you the loop and parsing; you write the four
syscall actions. Try it on a scratch file, then on `/proc/version`,
then on `/dev/null` — same tool, three very different things
pretending to be files.

## Part 2 — The kernel side: `submit/char_driver.c`

Now implement the other end for a device of your own: a character
driver whose "disk" is a 900-byte kernel buffer. The full contract
(major 511, name `simple_char_driver`, exact printk formats, standard
lseek semantics with clamping to `[0, 900]`) is written at the top of
the skeleton — the checks match it literally, including the dmesg
lines:

```
simple_char_driver: opened 3 times
simple_char_driver: closed 3 times
```

Two ideas do the heavy lifting:

- **`struct file_operations`** is the dispatch table. Registering it
  against major 511 is what makes `read(fd, ...)` on your device node
  arrive at *your* `scd_read` — the exact fork in the road your
  report's question 4 asks you to find.
- **`copy_to_user` / `copy_from_user`**: the user's buffer pointer
  lives in another address space (camp 4 made you watch those pages
  materialize). The kernel must not dereference user pointers
  directly; these helpers check and copy across the boundary.

### Build & load loop

`make check LAB=05-storage-and-io` builds the .ko automatically (a
host-side step runs before the VM boots; the first ever build also
indexes the kernel's exported symbols — a few minutes, once). For
iterating by hand:

```sh
# build (host, repo root; result lands in mod/)
mkdir -p mod && cp labs/05-storage-and-io/submit/char_driver.c mod/ \
  && printf 'obj-m := char_driver.o\n' > mod/Makefile
docker run --rm --platform linux/amd64 \
  -v kernel-lens-cache:/work/cache -v "$PWD/mod:/mod" kernel-lens-build \
  sh -c 'make -C /work/cache/linux-6.6.87 M=/mod modules \
         && objcopy --remove-section .BTF /mod/char_driver.ko'
# (the objcopy matters: module BTF is validated against the *running*
# kernel and drifts with the build tree — this course doesn't need it)

# load & poke (inside the VM: SHARE=$PWD/mod env/run.sh)
insmod /share/char_driver.ko
grep simple_char_driver /proc/devices        # registered at 511?
mknod /dev/simple_char_driver c 511 0
printf 'hi' > /dev/simple_char_driver
dd if=/dev/simple_char_driver bs=1 count=2   # hi
dmesg | tail                                 # your printks
rmmod char_driver
```

`mknod` is worth a pause: the `/dev` entry is just a name binding a
(major, minor) pair — *you* are creating the file that isn't a file.

## The capstone check

One scripted filetest session runs twice — once against a regular
file, once against `/dev/simple_char_driver` — and the outputs must be
**identical**. If they are, you have implemented "everything is a
file" rather than read about it.

## Check your work

```sh
make check LAB=05-storage-and-io      # Docker must be running
```

Checks: the filetest contract (read/write/seek/255, scripted stdin),
the module registering and unregistering cleanly, read/write/seek
through the device node, truncation at byte 900 and EOF after it, the
exact dmesg format, and the capstone comparison.

## Submit

Commit and push `submit/filetest.c`, `submit/char_driver.c`, and
`submit/report.md`: who owns the offset, why `copy_to_user` exists,
your buffer's afterlife across rmmod, and where the ext4 path and your
driver's path diverge in the kernel.
