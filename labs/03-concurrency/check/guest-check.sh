#!/bin/bash
# Basecamp 3 checks. Runs INSIDE the guest via the autorun channel.
# $1 = submission directory (mounted at /share/submit).
# Prints one "PASS <name>" or "FAIL <name>" line per check; the harness
# (scripts/check-lab.sh) counts FAIL lines and requires a CHECK-EXIT marker.
SUBMIT="${1:-/share/submit}"
CHECK="$(cd "$(dirname "$0")" && pwd)"

r() { local name="$1"; shift; if "$@" >/dev/null 2>&1; then echo "PASS $name"; else echo "FAIL $name"; fi }

# --- environment sanity ---
r boot            true
r proc-mounted    test -r /proc/1/comm
r gcc             command -v gcc

for f in race.c array.h array.c; do
    if [ ! -f "$SUBMIT/$f" ]; then
        echo "FAIL missing-$f"
        exit 1
    fi
done
r report-present  test -s "$SUBMIT/report.md"

# --- Part 1: race.c ---
r race-compiles   gcc -Wall -Werror -O2 -pthread -o /tmp/race "$SUBMIT/race.c"
# Defeating the demo with atomics is not passing it. // comments are
# stripped before matching.
rcode="$(sed 's|//.*||' "$SUBMIT/race.c")"
r no-atomics      sh -c "! printf '%s' \"\$1\" | grep -Eq '_Atomic|stdatomic|__atomic|atomic_fetch'" _ "$rcode"

if [ -x /tmp/race ]; then
    # racy must do real work AND lose updates, in at least 2 of 3 runs.
    lost=0
    for i in 1 2 3; do
        n="$(/tmp/race racy 2>/dev/null | sed -n 's/^COUNT=//p')"
        [ -n "$n" ] && [ "$n" -gt 0 ] && [ "$n" -lt 800000 ] && lost=$((lost + 1))
    done
    r racy-loses      test "$lost" -ge 2
    exact=0
    for i in 1 2 3; do
        n="$(/tmp/race locked 2>/dev/null | sed -n 's/^COUNT=//p')"
        [ "x$n" = "x800000" ] && exact=$((exact + 1))
    done
    r locked-exact    test "$exact" -eq 3
else
    echo "FAIL racy-loses"
    echo "FAIL locked-exact"
fi

# --- Part 2: the bounded buffer ---
# Blocking must be condvar-based, not a retry loop.
acode="$(sed 's|//.*||' "$SUBMIT/array.c")"
r uses-condvar    sh -c "printf '%s' \"\$1\" | grep -q pthread_cond_wait" _ "$acode"

r harness-compiles gcc -Wall -Werror -O2 -pthread -I"$SUBMIT" \
                       -o /tmp/array-test "$CHECK/array-test.c" "$SUBMIT/array.c"
if [ -x /tmp/array-test ]; then
    r roundtrip       /tmp/array-test roundtrip
    out="$(/tmp/array-test blocks-empty 2>/dev/null)"
    r blocks-empty    sh -c "printf '%s' \"\$1\" | grep -q '^OK blocks-empty'" _ "$out"
    cpu="$(printf '%s\n' "$out" | sed -n 's/^CPU_MS=//p')"
    # A condvar wait burns ~0 CPU over the 1 s window; a spinning
    # implementation burns ~1000 ms.
    r no-busy-wait    sh -c "test -n \"\$1\" && test \"\$1\" -lt 500" _ "$cpu"
    r blocks-full     /tmp/array-test blocks-full
    r stress          /tmp/array-test stress
else
    for c in roundtrip blocks-empty no-busy-wait blocks-full stress; do
        echo "FAIL $c"
    done
fi

exit 0
