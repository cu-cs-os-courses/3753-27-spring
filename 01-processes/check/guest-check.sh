#!/bin/bash
# Basecamp 1 checks. Runs INSIDE the guest via the autorun channel.
# $1 = submission directory (mounted at /share/submit).
# Prints one "PASS <name>" or "FAIL <name>" line per check; the harness
# (scripts/check-lab.sh) counts FAIL lines and requires a CHECK-EXIT marker.
SUBMIT="${1:-/share/submit}"

r() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS $name"; else echo "FAIL $name"; fi }

# --- environment sanity ---
r boot            true
r proc-mounted    test -r /proc/1/comm
r gcc             command -v gcc

for f in ptree.sh spawn.c undead.c; do
    if [ ! -f "$SUBMIT/$f" ]; then
        echo "FAIL missing-$f"
        exit 1
    fi
done
r report-present  test -s "$SUBMIT/report.md"

# --- Part 1: ptree.sh ---
# Comments stripped before matching, as in lab 0.
code="$(sed 's/#.*//' "$SUBMIT/ptree.sh")"
r no-ps           sh -c "! printf '%s' \"\$1\" | grep -qw ps" _ "$code"
r no-pstree       sh -c "! printf '%s' \"\$1\" | grep -qw pstree" _ "$code"
r uses-proc       sh -c "printf '%s' \"\$1\" | grep -q /proc" _ "$code"

# A child we control: its line is fully predictable, and the chain from
# here runs sleep -> this shell -> autorun -> kl-autorun -> systemd.
sleep 60 &
SP=$!
sleep 1   # let it reach nanosleep (state S)
PT="$(bash "$SUBMIT/ptree.sh" "$SP" 2>/dev/null)"
first="$(printf '%s\n' "$PT" | head -1)"
last="$(printf '%s\n' "$PT" | tail -1)"
r ptree-first     test "x$first" = "x$SP sleep S $$"
r ptree-last      test "x$last" = "x1 systemd S 0"
# Chain consistency: each line's PPID is the next line's PID.
r ptree-chain     awk 'NR>1 && $1 != prev {bad=1} {prev=$4} END {exit bad+0}' <<<"$PT"
kill "$SP" 2>/dev/null

# --- Part 2: spawn.c ---
r spawn-compiles  gcc -Wall -Werror -O2 -o /tmp/spawn "$SUBMIT/spawn.c"
if [ -x /tmp/spawn ]; then
    o="$(/tmp/spawn /bin/true)"
    r spawn-true      sh -c "printf '%s' \"\$1\" | grep -Eq '^CHILD [0-9]+ EXITED 0$'" _ "$o"
    o="$(/tmp/spawn /bin/false)"
    r spawn-false     sh -c "printf '%s' \"\$1\" | grep -Eq '^CHILD [0-9]+ EXITED 1$'" _ "$o"
    # The child's own output must land before the parent's report.
    o="$(/tmp/spawn /bin/echo hello)"
    r spawn-echo      sh -c "printf '%s\n' \"\$1\" | sed -n 1p | grep -q '^hello$' &&
                             printf '%s\n' \"\$1\" | sed -n 2p | grep -Eq '^CHILD [0-9]+ EXITED 0$'" _ "$o"
    o="$(/tmp/spawn /no/such/program 2>/dev/null)"
    r spawn-127       sh -c "printf '%s' \"\$1\" | grep -Eq '^CHILD [0-9]+ EXITED 127$'" _ "$o"
else
    for c in spawn-true spawn-false spawn-echo spawn-127; do echo "FAIL $c"; done
fi

# --- Part 3: undead.c ---
r undead-compiles gcc -Wall -Werror -O2 -o /tmp/undead "$SUBMIT/undead.c"
if [ -x /tmp/undead ]; then
    # zombie act: observe state Z from outside during the parent's sleep.
    /tmp/undead zombie > /tmp/z.out &
    UP=$!
    CP=""
    for i in $(seq 1 20); do
        CP="$(awk '/^CHILD /{print $2; exit}' /tmp/z.out 2>/dev/null)"
        [ -n "$CP" ] && break
        sleep 0.5
    done
    sawZ=1
    if [ -n "$CP" ]; then
        for i in $(seq 1 20); do
            st="$(awk '{print $3}' "/proc/$CP/stat" 2>/dev/null)"
            [ "$st" = "Z" ] && { sawZ=0; break; }
            sleep 0.5
        done
    fi
    r zombie-observed test "$sawZ" -eq 0
    wait "$UP" 2>/dev/null
    r zombie-reaped   grep -Eq "^REAPED $CP STATUS 42$" /tmp/z.out
    r zombie-gone     test ! -e "/proc/$CP"

    # orphan act: parent dies at once; the sleeping child's PPid must
    # become 1.
    /tmp/undead orphan > /tmp/o.out
    OP=""
    for i in $(seq 1 20); do
        OP="$(awk '/^CHILD /{print $2; exit}' /tmp/o.out 2>/dev/null)"
        [ -n "$OP" ] && break
        sleep 0.5
    done
    pp=""
    if [ -n "$OP" ]; then
        for i in $(seq 1 20); do
            pp="$(sed -n 's/^PPid:\t//p' "/proc/$OP/status" 2>/dev/null)"
            [ "$pp" = "1" ] && break
            sleep 0.5
        done
    fi
    r orphan-ppid1    test "x$pp" = "x1"
else
    for c in zombie-observed zombie-reaped zombie-gone orphan-ppid1; do echo "FAIL $c"; done
fi

exit 0
