#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f -- "$0")")"

. "$HERE/../repo.sh"

SHARED_OVERLAY_DIR="$REPO_DIR/build-overlay"
SHARED_WORK_DIR="$REPO_DIR/build-work"
SRC_DIR="$REPO_DIR/src"

OVERLAY_DIR=""
WORK_DIR=""

mount_overlay() {
    sudo mount -t overlay overlay "$@"
}

MOUNTSD=()
UMOUNT_HOOK_DONE=0

umount_hook() {
    if [ "$UMOUNT_HOOK_DONE" = 1 ]; then
        return
    fi
    popd > /dev/null
    local mount
    for mount in "${MOUNTSD[@]}"; do
        while ! sudo umount "$mount"; do
            sleep 0.1
        done
    done
    UMOUNT_HOOK_DONE=1
    trap - EXIT
}

ovl_bootstrap() {
    local upper="$OVERLAY_DIR/upper" work="$OVERLAY_DIR/work"
    mkdir -p "$WORK_DIR" "$upper" "$work"
    sudo mount -t overlay overlay "$WORK_DIR" \
        -o lowerdir="$SRC_DIR",upperdir="$upper",workdir="$work"
    MOUNTSD+=("$WORK_DIR")
}

ovl_default() {
    local upper="$OVERLAY_DIR/upper" work="$OVERLAY_DIR/work"
    mkdir -p "$WORK_DIR" "$upper" "$work"
    sudo mount -t overlay overlay "$WORK_DIR" \
        -o lowerdir="$SRC_DIR":"$SHARED_OVERLAY_DIR"/bootstrap/upper,upperdir="$upper",workdir="$work"
    MOUNTSD+=("$WORK_DIR")
}

main() {
    if [ -z "${STAGENAME:-}" ]; then
        echo "NO STAGE NAME" > /dev/stderr
        exit 1
    fi
    OVERLAY_DIR="$SHARED_OVERLAY_DIR/$STAGENAME"
    WORK_DIR="$SHARED_WORK_DIR/$STAGENAME"
    if [ "$STAGENAME" == "bootstrap" ]; then
        ovl_bootstrap
    else
        ovl_default
    fi
    trap umount_hook EXIT
    pushd "$WORK_DIR" > /dev/null
    "$@"
    umount_hook
}

_entry() {
    set -euo pipefail
    main "$@"
    eval "exit 0"
}

_entry "$@"
