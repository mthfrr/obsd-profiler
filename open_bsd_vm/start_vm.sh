#!/bin/sh

qemu-system-x86_64 \
    -smp "cpus=4" \
    -m 4G \
    -hda obsd.qcow2 \
    -nic user,hostfwd=tcp::10022-:22 \
    --nographic
