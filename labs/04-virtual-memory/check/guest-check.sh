#!/bin/bash
# Basecamp 4 checks. Runs INSIDE the guest via the autorun channel.
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

for f in touch.c pager-lru.c; do
    if [ ! -f "$SUBMIT/$f" ]; then
        echo "FAIL missing-$f"
        exit 1
    fi
done
r report-present  test -s "$SUBMIT/report.md"

# --- Part 1: touch.c ---
r touch-compiles  gcc -Wall -Werror -O2 -o /tmp/touch "$SUBMIT/touch.c"
if [ -x /tmp/touch ]; then
    out="$(/tmp/touch 2>/dev/null)"
    get() { printf '%s\n' "$out" | sed -n "s/^$1=//p" | head -1; }
    b="$(get RSS_KB_BEFORE)"; a="$(get RSS_KB_AFTER)"; m="$(get FAULT_DELTA)"
    # 64 MiB = 65536 kB resident growth; 16384 pages faulted. Slack for
    # allocator/runtime noise.
    r touch-rss       sh -c "test -n \"\$1\" && test -n \"\$2\" && test \"\$1\" -ge 0 && test \$((\$2 - \$1)) -ge 60000" _ "$b" "$a"
    r touch-faults    sh -c "test -n \"\$1\" && test \"\$1\" -ge 14000" _ "$m"
else
    echo "FAIL touch-rss"
    echo "FAIL touch-faults"
fi

# --- Part 2: pager-lru.c ---
r pager-compiles  gcc -Wall -Werror -O2 -I"$CHECK/sim" -o /tmp/test-lru \
                      "$CHECK/sim/simulator.c" "$CHECK/sim/programs.c" "$SUBMIT/pager-lru.c"
if [ -x /tmp/test-lru ]; then
    ratio() { timeout 120 /tmp/test-lru -seed "$1" 2>&1 | sed -n 's/.*ratio blocked\/compute=//p' | head -1; }
    r1="$(ratio 1)"
    r pager-runs      test -n "$r1"
    if [ -n "$r1" ]; then
        r deterministic   test "x$r1" = "x$(ratio 1)"
        # pager-basic scores ~15; any real paging policy clears 5.12.
        r beats-baseline  awk -v x="$r1" 'BEGIN{exit !(x < 5.12)}'
        r2="$(ratio 2)"; r3="$(ratio 3)"
        # Passing bar: average over seeds 1-3 below 1.28 (the legacy
        # 30-point band; the reference LRU averages 0.19).
        r lru-works       awk -v a="$r1" -v b="$r2" -v c="$r3" \
                              'BEGIN{exit !(b != "" && c != "" && (a+b+c)/3 < 1.28)}'
    else
        for c in deterministic beats-baseline lru-works; do echo "FAIL $c"; done
    fi
else
    for c in pager-runs deterministic beats-baseline lru-works; do echo "FAIL $c"; done
fi

exit 0
