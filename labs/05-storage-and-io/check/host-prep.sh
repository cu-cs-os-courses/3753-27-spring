#!/bin/bash
# Basecamp 5 host-prep: build submit/char_driver.c into a kernel module
# for the pinned kernel, using the env build container. Runs on the
# HOST (kernel builds can't happen inside the guest — it has no kernel
# tree). Result: $WORK/mod/char_driver.ko, which the guest sees at
# /share/mod/char_driver.ko.
#
# A student compile error is NOT a host-prep failure: we print the
# compiler output and exit 0 with no .ko, so the guest-side
# module-built check FAILs cleanly. Nonzero exit is reserved for
# environment problems (no docker, no build image).
set -uo pipefail
WORK="${1:?usage: host-prep.sh <workdir> <repodir>}"
REPO="${2:?usage: host-prep.sh <workdir> <repodir>}"
source "$REPO/env/config.sh"

command -v docker >/dev/null || {
    echo "host-prep: docker not found — lab 5's module build needs Docker running (see the lab README)"
    exit 1
}
docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1 || {
    echo "host-prep: build container image missing — run 'cd env && make images' first"
    exit 1
}

[ -f "$WORK/submit/char_driver.c" ] || exit 0  # guest check reports missing-file

# Docker file sharing (colima on macOS) covers the repo but not
# TMPDIR, so the build must stage under the repo.
STAGE="$(mktemp -d "$REPO/.modbuild.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
cp "$WORK/submit/char_driver.c" "$STAGE/"
printf 'obj-m := char_driver.o\n' > "$STAGE/Makefile"

# 'make images' builds bzImage only, which never generates
# Module.symvers; external-module builds need it. Heal once — the
# result persists in the kernel-lens-cache volume.
if ! docker run --rm --platform linux/amd64 -v kernel-lens-cache:/work/cache \
        "$DOCKER_IMAGE" test -f "/work/cache/linux-$KERNEL_VERSION/Module.symvers"; then
    echo "==> one-time: indexing kernel exports (make modules — a few minutes, cached forever)"
    docker run --rm --platform linux/amd64 -v kernel-lens-cache:/work/cache \
        "$DOCKER_IMAGE" sh -c "cd /work/cache/linux-$KERNEL_VERSION && make -j\"\$(nproc)\" modules" || {
        echo "host-prep: kernel module index build failed"
        exit 1
    }
fi

echo "==> building char_driver.ko against linux-$KERNEL_VERSION"
# The .BTF strip mirrors the legacy build: module BTF must validate
# against the RUNNING kernel's BTF, which drifts whenever the cached
# tree is touched (e.g. the make-modules heal above). This course
# doesn't need module BTF; without the section the kernel skips the
# validation.
if docker run --rm --platform linux/amd64 \
        -v kernel-lens-cache:/work/cache -v "$STAGE:/mod" "$DOCKER_IMAGE" \
        sh -c "make -C /work/cache/linux-$KERNEL_VERSION M=/mod modules \
               && objcopy --remove-section .BTF /mod/char_driver.ko" 2>&1 | tail -20 \
   && [ -f "$STAGE/char_driver.ko" ]; then
    mkdir -p "$WORK/mod"
    cp "$STAGE/char_driver.ko" "$WORK/mod/char_driver.ko"
else
    echo "host-prep: char_driver.c did not compile — the module-built check will FAIL"
fi
exit 0
