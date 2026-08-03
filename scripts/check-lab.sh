#!/bin/bash
# Run one lab's checks against a submission, inside the reference VM.
#
#   scripts/check-lab.sh <lab-dir> [submission-dir]
#
#   <lab-dir>         lab directory containing check/guest-check.sh
#   [submission-dir]  the student's submit/ directory
#                     (default: <lab-dir>/submit — i.e. self-check)
#
# The check script always comes from <lab-dir> (the instructor tree when a
# TA runs this), never from the submission — a student editing check/ in
# their own repo has no effect on grading.
#
# Mechanism: the guest boots headless, kl-autorun runs /share/autorun.sh,
# which executes check/guest-check.sh with the submission at /share/submit
# and powers off. We assert on the files the guest left behind — no serial
# parsing, no expect scripting (same pattern as env/scripts/smoke-test.sh).
#
# Exit 0 iff the guest finished and reported zero FAIL lines.
# Last stdout line is machine-readable:
#   RESULT lab=<name> status=<pass|fail|error> passes=N fails=M
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LAB_DIR="$(cd "${1:?usage: check-lab.sh <lab-dir> [submission-dir]}" && pwd)"
SUBMIT_DIR="$(cd "${2:-$LAB_DIR/submit}" && pwd)"
LAB_NAME="$(basename "$LAB_DIR")"
TIMEOUT="${TIMEOUT:-900}"   # TCG on Apple Silicon is slow; be generous.

[ -x "$LAB_DIR/check/guest-check.sh" ] || {
    echo "ERROR: $LAB_DIR/check/guest-check.sh missing or not executable"
    echo "RESULT lab=$LAB_NAME status=error passes=0 fails=0"
    exit 2
}

WORK="$(mktemp -d "${TMPDIR:-/tmp}/bc-check.XXXXXX")"
QEMU_PID=""
# Keep $WORK on failure — console.log and result.txt are the only evidence
# for diagnosing a bad run. Only a fully passing run cleans up.
trap '[ -n "$QEMU_PID" ] && kill "$QEMU_PID" 2>/dev/null || true; echo "(artifacts kept at $WORK)"' EXIT

cp -R "$LAB_DIR/check" "$WORK/check"
cp -R "$SUBMIT_DIR" "$WORK/submit"

# Optional host-side prep: labs that need work the guest can't do (e.g.
# lab 5's kernel-module build in the env's Docker container) provide
# check/host-prep.sh. It runs on the HOST, after the submission is
# staged and before boot. A nonzero exit is an environment error, not a
# grading result (submission problems must surface as guest-side FAILs).
if [ -x "$WORK/check/host-prep.sh" ]; then
    echo "==> [$LAB_NAME] host-prep"
    if ! "$WORK/check/host-prep.sh" "$WORK" "$REPO_DIR"; then
        echo "ERROR: host-prep failed (environment problem — see output above)"
        echo "RESULT lab=$LAB_NAME status=error passes=0 fails=0"
        exit 2
    fi
fi

cat > "$WORK/autorun.sh" <<'EOF'
#!/bin/bash
bash /share/check/guest-check.sh /share/submit > /share/result.txt 2>&1
echo "CHECK-EXIT $?" >> /share/result.txt
poweroff
EOF
chmod +x "$WORK/autorun.sh"

echo "==> [$LAB_NAME] booting VM headless (timeout ${TIMEOUT}s)"
SHARE="$WORK" HEADLESS=1 CONSOLE_LOG="$WORK/console.log" "$REPO_DIR/env/run.sh" &
QEMU_PID=$!

waited=0
while kill -0 "$QEMU_PID" 2>/dev/null; do
    sleep 5; waited=$((waited + 5))
    if [ "$waited" -ge "$TIMEOUT" ]; then
        echo "ERROR: timed out after ${TIMEOUT}s. Console tail:"
        tail -30 "$WORK/console.log" 2>/dev/null || true
        echo "RESULT lab=$LAB_NAME status=error passes=0 fails=0"
        exit 1
    fi
done
QEMU_PID=""

if [ ! -f "$WORK/result.txt" ]; then
    echo "ERROR: guest never wrote result.txt (autorun/9p failure). Console tail:"
    tail -30 "$WORK/console.log" 2>/dev/null || true
    echo "RESULT lab=$LAB_NAME status=error passes=0 fails=0"
    exit 1
fi

echo "==> [$LAB_NAME] VM exited after ~${waited}s. Results:"
cat "$WORK/result.txt"

passes=$(grep -c '^PASS' "$WORK/result.txt" || true)
fails=$(grep -c '^FAIL' "$WORK/result.txt" || true)
if ! grep -q '^CHECK-EXIT' "$WORK/result.txt"; then
    echo "ERROR: check script did not finish"
    echo "RESULT lab=$LAB_NAME status=error passes=$passes fails=$fails"
    exit 1
fi

if [ "$fails" -eq 0 ]; then
    echo "RESULT lab=$LAB_NAME status=pass passes=$passes fails=$fails"
    trap - EXIT
    rm -rf "$WORK"
else
    echo "RESULT lab=$LAB_NAME status=fail passes=$passes fails=$fails"
    exit 1
fi
