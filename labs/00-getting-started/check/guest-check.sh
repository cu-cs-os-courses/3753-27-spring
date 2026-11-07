#!/bin/bash
# Basecamp 0 checks. Runs INSIDE the guest via the autorun channel.
# $1 = submission directory (mounted at /share/submit).
# Prints one "PASS <name>" or "FAIL <name>" line per check; the harness
# (scripts/check-lab.sh) counts FAIL lines and requires a CHECK-EXIT marker.
SUBMIT="${1:-/share/submit}"

r() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS $name"; else echo "FAIL $name"; fi }

# --- environment sanity (also serves as the student's env verification) ---
r boot            true
r proc-mounted    test -r /proc/1/comm

# --- student submission: observe.sh ---
if [ ! -f "$SUBMIT/observe.sh" ]; then
    echo "FAIL observe-script-missing"
    exit 1
fi

# observe.sh must not shell out to the convenience binaries it is meant to
# replace — the point of the lab is reading /proc directly. Comments are
# stripped before matching so the starter file's own instructions don't trip
# the check.
code="$(sed 's/#.*//' "$SUBMIT/observe.sh")"
r no-uname        sh -c "! printf '%s' \"\$1\" | grep -qw uname" _ "$code"
r no-nproc        sh -c "! printf '%s' \"\$1\" | grep -qw nproc" _ "$code"

# Run observe.sh as a direct child of this shell (not inside $( ), which
# may fork a subshell first), so its PPid: is exactly this shell's $$.
bash "$SUBMIT/observe.sh" > /tmp/observe.out 2>/dev/null
out="$(cat /tmp/observe.out)"
get() { printf '%s\n' "$out" | sed -n "s/^$1=//p" | head -1; }
kr="$(get KERNEL_RELEASE)"
np="$(get NPROC)"
p1="$(get PID1_COMM)"
mt="$(get MEM_TOTAL_KB)"
ut="$(get UPTIME_S)"
sp="$(get SHELL_PPID)"
ct="$(get CTXT)"
np2="$(get NUM_PROCS)"

r kernel-release  test "x$kr" = "x$(uname -r)"
r nproc           test "x$np" = "x$(nproc)"
r pid1-comm       test "x$p1" = "x$(cat /proc/1/comm)"
r mem-total       test "$mt" -gt 0
# Whole seconds since boot: an integer, positive, and no larger than a
# reading taken now.
r uptime          sh -c "printf '%s' \"\$1\" | grep -Eq '^[0-9]+$' && test \"\$1\" -gt 0 && test \"\$1\" -le \"\$(cut -d. -f1 /proc/uptime)\"" _ "$ut"
r shell-ppid      test "x$sp" = "x$$"
# ctxt is monotonic: the submission's reading must be positive and no
# larger than a reading taken now.
r ctxt            sh -c "test \"\$1\" -gt 0 && test \"\$1\" -le \"\$(awk '/^ctxt /{print \$2}' /proc/stat)\"" _ "$ct"
# Loose floor: even a minimal guest has dozens of PIDs (kernel threads).
r num-procs       test "$np2" -ge 10

exit 0
