/* Basecamp 2, Part 1 — make load.
 *
 * Usage: spin
 *
 * Burn CPU in userspace, forever. That is the entire specification —
 * the scheduler supplies the plot. The checker runs this pinned to a
 * CPU and expects it to (a) consume nearly all of that CPU's time and
 * (b) sit in state R whenever it is observed.
 *
 * Hint: an optimizer is allowed to delete a loop that provably does
 * nothing. `volatile` is how you forbid the proof.
 *
 * Verify locally with:  make check LAB=02-scheduling
 */

int main(void)
{
    /* TODO: loop forever, doing (almost) nothing. */

    return 0;
}
