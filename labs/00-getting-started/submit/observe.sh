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
#   NPROC=<number of CPUs the kernel is using>
#   PID1_COMM=<the command name of PID 1>
#   MEM_TOTAL_KB=<total main memory in kB as the kernel reports it>
#   UPTIME_S=<whole seconds since boot, from the first number in /proc/uptime>
#   SHELL_PPID=<the PPid: field of /proc/$$/status>
#   CTXT=<total context switches since boot, from /proc/stat>
#   NUM_PROCS=<number of processes in the process table right now>
#
# Hints:
#   - UPTIME_S: the first number has a fraction (e.g. 83.42). Print only
#     the whole seconds before the decimal point (83), without rounding.
#   - SHELL_PPID: inside this script, $$ is the PID of the bash that runs
#     the script, so /proc/$$/status is its status file. Its PPid: line
#     names its parent, the shell you typed the command in.
#   - NUM_PROCS: every process is a numeric directory under /proc; count
#     them.
#
# Verify locally with:  make check LAB=00-getting-started   (from the repository root)

echo "KERNEL_RELEASE=$(: TODO)"
echo "NPROC=$(: TODO)"
echo "PID1_COMM=$(: TODO)"
echo "MEM_TOTAL_KB=$(: TODO)"
echo "UPTIME_S=$(: TODO)"
echo "SHELL_PPID=$(: TODO)"
echo "CTXT=$(: TODO)"
echo "NUM_PROCS=$(: TODO)"
