#!/bin/bash
# Basecamp 2 checks. Runs INSIDE the guest via the autorun channel.
# $1 = submission directory (mounted at /share/submit).
# Prints one "PASS <name>" or "FAIL <name>" line per check; the harness
# (scripts/check-lab.sh) counts FAIL lines and requires a CHECK-EXIT marker.
#
# Discipline: every experiment pins its spinners to CPU 0; this script
# stays unpinned (CPU 1 is free), so nothing here can be starved.
SUBMIT="${1:-/share/submit}"

r() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS $name"; else echo "FAIL $name"; fi }

# Kill every process whose comm is "spin" — the backstop against a
# submission (or a failed check) leaking a CPU-pegging spinner into the
# next measurement. Pure /proc, no pkill dependency.
killall_spin() {
    local d
    for d in /proc/[0-9]*; do
        [ "$(cat "$d/comm" 2>/dev/null)" = "spin" ] && kill -9 "${d#/proc/}" 2>/dev/null
    done
    sleep 0.5
    return 0
}
trap killall_spin EXIT

# --- environment sanity ---
r boot            true
r proc-mounted    test -r /proc/1/comm
r gcc             command -v gcc
r sched-tools     sh -c "command -v taskset && command -v chrt"

for f in spin.c fairshare.sh; do
    if [ ! -f "$SUBMIT/$f" ]; then
        echo "FAIL missing-$f"
        exit 1
    fi
done
r report-present  test -s "$SUBMIT/report.md"

# --- Part 2 statics (before anything runs) ---
code="$(sed 's/#.*//' "$SUBMIT/fairshare.sh")"
r no-top          sh -c "! printf '%s' \"\$1\" | grep -qw top" _ "$code"
r no-ps           sh -c "! printf '%s' \"\$1\" | grep -qw ps" _ "$code"
r uses-proc       sh -c "printf '%s' \"\$1\" | grep -q /proc" _ "$code"

# --- Part 1: spin.c ---
r spin-compiles   gcc -Wall -Werror -O2 -o /tmp/spin "$SUBMIT/spin.c"
if [ ! -x /tmp/spin ]; then
    for c in spin-pegs-cpu spin-state-R preemption-visible \
             fair-format fair-equal fair-nice10 fifo-throttle; do
        echo "FAIL $c"
    done
    exit 0
fi

# Pegs its CPU: pinned alone on CPU 0, utime (USER_HZ=100) over 5 s
# should be ~500 ticks; demand at least 300.
taskset -c 0 /tmp/spin & SP=$!; disown
sleep 1
u0="$(awk '{print $14}' "/proc/$SP/stat" 2>/dev/null)"
sleep 5
u1="$(awk '{print $14}' "/proc/$SP/stat" 2>/dev/null)"
st="$(awk '{print $3}' "/proc/$SP/stat" 2>/dev/null)"
r spin-pegs-cpu   test $((u1 - u0)) -ge 300
r spin-state-R    test "x$st" = "xR"
killall_spin

# Preemption visible: two spinners on one CPU force involuntary
# switches on each other.
taskset -c 0 /tmp/spin & P1=$!; disown
taskset -c 0 /tmp/spin & disown
sleep 1
s0="$(awk '/^nr_involuntary_switches/{print $3}' "/proc/$P1/sched" 2>/dev/null)"
sleep 5
s1="$(awk '/^nr_involuntary_switches/{print $3}' "/proc/$P1/sched" 2>/dev/null)"
r preemption-visible test $((s1 - s0)) -ge 5
killall_spin

# --- Part 2: fairshare.sh, functional ---
out="$(SPIN=/tmp/spin bash "$SUBMIT/fairshare.sh" 0 0 10 2>/dev/null | tail -1)"
killall_spin
r fair-format     sh -c "printf '%s' \"\$1\" | grep -Eq '^A=[0-9]+ B=[0-9]+ RATIO=[0-9]+\.[0-9]{2}$'" _ "$out"
ratio="${out##*RATIO=}"
r fair-equal      awk -v x="$ratio" 'BEGIN{exit !(x >= 0.6 && x <= 1.6)}'

out="$(SPIN=/tmp/spin bash "$SUBMIT/fairshare.sh" 0 10 15 2>/dev/null | tail -1)"
killall_spin
ratio="${out##*RATIO=}"
# Measured 9.35 on the reference VM, theory 9.31; band is generous for
# noisy student laptops.
r fair-nice10     awk -v x="$ratio" 'BEGIN{exit !(x >= 6.0 && x <= 13.0)}'

# --- Part 3: policy beats weight (checker-driven) ---
taskset -c 0 /tmp/spin & N=$!; disown
taskset -c 0 chrt -f 50 /tmp/spin & F=$!; disown
sleep 2
n0="$(awk '{print $14}' "/proc/$N/stat" 2>/dev/null)"
f0="$(awk '{print $14}' "/proc/$F/stat" 2>/dev/null)"
sleep 10
n1="$(awk '{print $14}' "/proc/$N/stat" 2>/dev/null)"
f1="$(awk '{print $14}' "/proc/$F/stat" 2>/dev/null)"
killall_spin
# RT throttling gives the normal task ~5%; accept 2-10%.
r fifo-throttle   awk -v n=$((n1 - n0)) -v f=$((f1 - f0)) \
                      'BEGIN{s = n / (n + f + 0.001); exit !(s >= 0.02 && s <= 0.10)}'

exit 0
