/* Basecamp 5, Part 2 — the kernel side: a character device driver.
 *
 * The same five verbs your filetest invokes — open, release, read,
 * write, llseek — implemented instead of called. The device is a
 * 900-byte kernel buffer; your filetest from Part 1 must drive it
 * exactly like a regular file (the checks do precisely that).
 *
 * The contract, exactly (the checks match these):
 *   - major number 511, device name "simple_char_driver"
 *   - init: kzalloc the 900-byte buffer, register_chrdev
 *   - exit: unregister_chrdev, kfree
 *   - open:    count the open and
 *              printk(KERN_INFO "simple_char_driver: opened %d times\n", ...)
 *   - release: printk(KERN_INFO "simple_char_driver: closed %d times\n", ...)
 *              (same running counter)
 *   - read:  copy_to_user from buffer at *offset; never past
 *            BUFFER_SIZE (at the end, return 0 — that is EOF);
 *            advance *offset; return bytes read
 *   - write: copy_from_user into buffer at *offset; truncate at
 *            BUFFER_SIZE; advance *offset; return bytes written
 *   - llseek: STANDARD semantics — SEEK_SET: off; SEEK_CUR: pos+off;
 *            SEEK_END: BUFFER_SIZE+off (off is usually negative);
 *            clamp the result to [0, BUFFER_SIZE]; set and return it
 *
 * Build & load: `make check LAB=05-storage-and-io` builds the .ko on
 * the host automatically; the Lab05 walkthrough shows the manual loop
 * for iterating.
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

MODULE_LICENSE("GPL");

#define BUFFER_SIZE  900
#define MAJOR_NUMBER 511
#define DEVICE_NAME  "simple_char_driver"

static char *device_buffer;
static int open_count;

static int scd_open(struct inode *inode, struct file *filp)
{
    /* TODO */
    return 0;
}

static int scd_release(struct inode *inode, struct file *filp)
{
    /* TODO */
    return 0;
}

static ssize_t scd_read(struct file *filp, char __user *buf,
                        size_t len, loff_t *offset)
{
    /* TODO */
    return 0;
}

static ssize_t scd_write(struct file *filp, const char __user *buf,
                         size_t len, loff_t *offset)
{
    /* TODO */
    return 0;
}

static loff_t scd_llseek(struct file *filp, loff_t offset, int whence)
{
    /* TODO */
    return 0;
}

static struct file_operations scd_fops = {
    .owner   = THIS_MODULE,
    .open    = scd_open,
    .release = scd_release,
    .read    = scd_read,
    .write   = scd_write,
    .llseek  = scd_llseek,
};

static int __init scd_init(void)
{
    /* TODO: allocate the buffer (kzalloc), register the device; on
     * registration failure, free the buffer and return a negative
     * errno. */

    /* The three casts below only keep the UNFILLED skeleton building
     * under the kernel's -Werror (unused-variable). Delete them once
     * your init actually uses these. */
    (void)scd_fops;
    (void)device_buffer;
    (void)open_count;
    return 0;
}

static void __exit scd_exit(void)
{
    /* TODO: unregister, free. */
}

module_init(scd_init);
module_exit(scd_exit);
