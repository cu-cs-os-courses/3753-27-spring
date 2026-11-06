#!/bin/bash
# Basecamp 0 — Learning to See a Running System
#
# Fill in each TODO so this script prints the eight lines below, with the
# values read from the /proc filesystem. Rules:
#   - You may only READ files under /proc (cat, grep, awk, sed, etc.).
#   - Do NOT call uname, nproc, or similar convenience tools — the point
#     is to find where the kernel itself exposes these facts.
#
# Expected output format (order matters, one KEY=VALUE per line):
#   KERNEL_RELEASE=<the running kernel's release string>
#   NPROC=<number of online CPUs>
#   PID1_COMM=<the command name of PID 1>
#   MEM_TOTAL_KB=<total physical memory in kB>
#   BOOT_CMDLINE=<the command line the kernel was booted with>
#   SELF_PID=<the PID of whoever is reading /proc/self — run this twice>
#   CTXT=<total context switches since boot, from /proc/stat>
#   NUM_PROCS=<number of processes in the process table right now>
#
# Hints:
#   - BOOT_CMDLINE: compare it with the -append line in env/run.sh.
#   - SELF_PID: /proc/self is a different directory for every process that
#     looks at it. Use it — do not use the shell's $$.
#   - NUM_PROCS: every process is a numeric directory under /proc; count
#     them. (You'll count kernel threads too — that's fine, and worth a
#     look: compare with `ps aux`.)
#
# Verify locally with:  make check LAB=00-getting-started   (from the repository root)

echo "KERNEL_RELEASE=$(: TODO)"
echo "NPROC=$(: TODO)"
echo "PID1_COMM=$(: TODO)"
echo "MEM_TOTAL_KB=$(: TODO)"
echo "BOOT_CMDLINE=$(: TODO)"
echo "SELF_PID=$(: TODO)"
echo "CTXT=$(: TODO)"
echo "NUM_PROCS=$(: TODO)"
