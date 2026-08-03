#!/bin/bash
# Basecamp 2, Part 2 — the meaning of nice.
#
# Usage: fairshare.sh <niceA> <niceB> <seconds>
#
# Start two copies of your compiled spin binary (path in $SPIN, default
# /tmp/spin), BOTH pinned to CPU 0, at nice <niceA> and nice <niceB>.
# Let them fight for <seconds> seconds, then print exactly one line:
#
#   A=<utimeA> B=<utimeB> RATIO=<A divided by B, 2 decimals>
#
# where utimeA/utimeB are each spinner's utime GROWTH over the window —
# field 14 of /proc/<pid>/stat (a lab-1 acquaintance). Kill both
# spinners before you exit, success or failure. Rules:
#   - Read only /proc. No top, no ps, no pidstat.
#
# Hints:
#   - taskset -c 0 nice -n "$na" "$SPIN" &   — and $! is its pid.
#   - Give them 2-3 seconds of warm-up before opening the measurement
#     window, so startup cost doesn't pollute it.
#   - awk does floating point:  awk -v a="$da" -v b="$db" 'BEGIN{...}'
#   - trap '...' EXIT is the reliable way to never leak a spinner.
#
# Verify locally with:  make check LAB=02-scheduling

SPIN="${SPIN:-/tmp/spin}"
na="${1:?usage: fairshare.sh <niceA> <niceB> <seconds>}"
nb="${2:?usage: fairshare.sh <niceA> <niceB> <seconds>}"
secs="${3:?usage: fairshare.sh <niceA> <niceB> <seconds>}"

# TODO: start the two pinned, niced spinners; warm up; sample both
# utimes; sleep "$secs"; sample again; kill the spinners; print the
# A= B= RATIO= line.
