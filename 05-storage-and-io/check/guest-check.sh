#!/bin/bash
# Basecamp 5 checks. Runs INSIDE the guest via the autorun channel.
# $1 = submission directory (mounted at /share/submit). The kernel
# module was built on the HOST by check/host-prep.sh and arrives at
# /share/mod/char_driver.ko.
# Prints one "PASS <name>" or "FAIL <name>" line per check; the harness
# (scripts/check-lab.sh) counts FAIL lines and requires a CHECK-EXIT marker.
SUBMIT="${1:-/share/submit}"
MOD="${MOD:-/share/mod}"

r() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS $name"; else echo "FAIL $name"; fi }

# --- environment sanity ---
r boot            true
r proc-mounted    test -r /proc/1/comm
r gcc             command -v gcc

for f in filetest.c char_driver.c; do
    if [ ! -f "$SUBMIT/$f" ]; then
        echo "FAIL missing-$f"
        exit 1
    fi
done
r report-present  test -s "$SUBMIT/report.md"

# --- Part 1: filetest.c (userspace, scripted stdin) ---
r filetest-compiles gcc -Wall -Werror -O2 -o /tmp/filetest "$SUBMIT/filetest.c"
if [ -x /tmp/filetest ]; then
    printf 'hello, basecamp!' > /tmp/fx   # 16 bytes, no newline

    out="$(printf 'r 5\nq\n' | /tmp/filetest /tmp/fx 2>/dev/null)"
    r ft-read         test "x$out" = "x$(printf 'READ 5 hello')"

    rm -f /tmp/f2
    out="$(printf 'w abcdef\ns 0 set\nr 6\nq\n' | /tmp/filetest /tmp/f2 2>/dev/null)"
    r ft-roundtrip    test "x$out" = "x$(printf 'WROTE 6\nOFFSET 0\nREAD 6 abcdef')"

    out="$(printf 's 7 set\nr 8\ns -8 end\nr 8\ns 0 cur\nq\n' | /tmp/filetest /tmp/fx 2>/dev/null)"
    r ft-seek         test "x$out" = "x$(printf 'OFFSET 7\nREAD 8 basecamp\nOFFSET 8\nREAD 8 asecamp!\nOFFSET 16')"

    printf 'q\n' | /tmp/filetest /nonexistent-dir/f >/dev/null 2>&1
    r ft-exit-255     test "$?" -eq 255
else
    for c in ft-read ft-roundtrip ft-seek ft-exit-255; do echo "FAIL $c"; done
fi

# --- Part 2: char_driver.ko (built by host-prep) ---
r module-built    test -f "$MOD/char_driver.ko"
if [ -f "$MOD/char_driver.ko" ] && insmod "$MOD/char_driver.ko" 2>/dev/null; then
    r drv-registered  grep -q "^511 simple_char_driver$" /proc/devices
    mknod /dev/simple_char_driver c 511 0

    printf 'hello world' 2>/dev/null > /dev/simple_char_driver
    r drv-roundtrip   test "x$(dd if=/dev/simple_char_driver bs=1 count=11 2>/dev/null)" = "xhello world"
    r drv-seek        test "x$(dd if=/dev/simple_char_driver bs=1 skip=6 count=5 2>/dev/null)" = "xworld"

    # Writes truncate at 900; reads at the end return 0 (EOF).
    dd if=/dev/zero of=/dev/simple_char_driver bs=1200 count=1 conv=notrunc >/dev/null 2>&1
    n="$(dd if=/dev/simple_char_driver bs=1 skip=895 count=100 2>/dev/null | wc -c)"
    r drv-clamp       test "$n" -eq 5

    r drv-dmesg-open  sh -c "dmesg | grep -Eq 'simple_char_driver: opened [0-9]+ times'"

    # The thesis: the student's own filetest drives the student's own
    # device exactly like a regular file (inside the 900-byte world).
    session='w kernel-mode\ns 0 set\nr 11\ns 0 cur\nq\n'
    rm -f /tmp/plain
    a="$(printf "$session" | /tmp/filetest /tmp/plain 2>/dev/null)"
    b="$(printf "$session" | /tmp/filetest /dev/simple_char_driver 2>/dev/null)"
    r composition     sh -c "test -n \"\$1\" && test \"x\$1\" = \"x\$2\"" _ "$a" "$b"

    rmmod char_driver 2>/dev/null
    r drv-unregistered sh -c "! grep -q simple_char_driver /proc/devices"
else
    for c in drv-registered drv-roundtrip drv-seek drv-clamp \
             drv-dmesg-open composition drv-unregistered; do
        echo "FAIL $c"
    done
fi

exit 0
