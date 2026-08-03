#!/bin/bash
# Basecamp 1, Part 1 — the family tree.
#
# Usage: ptree.sh <pid>
#
# Print the ancestry chain of <pid>: one line for <pid> itself, one for
# its parent, and so on up the tree, ending with the line for PID 1.
# Each line, exactly:
#
#   <PID> <COMM> <STATE> <PPID>
#
# where COMM is the Name: field, STATE is the single capital letter of
# the State: field (S, not "S (sleeping)"), and PPID is the PPid: field
# — all read from /proc/<pid>/status. Rules:
#   - Read only /proc. Do NOT call ps or pstree.
#
# Verify locally with:  make check LAB=01-processes

pid="${1:?usage: ptree.sh <pid>}"

# TODO: loop — read Name/State/PPid from /proc/$pid/status, print this
# process's line, stop once you have printed the line for PID 1,
# otherwise continue with the parent.
