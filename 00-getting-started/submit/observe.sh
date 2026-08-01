#!/bin/bash
# Basecamp 0 — Learning to See a Running System
#
# Fill in each TODO so this script prints the four lines below, with the
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
#
# Verify locally with:  make check   (from the repository root)

echo "KERNEL_RELEASE=$(: TODO)"
echo "NPROC=$(: TODO)"
echo "PID1_COMM=$(: TODO)"
echo "MEM_TOTAL_KB=$(: TODO)"
