#!/bin/sh

qemu-system-x86_64 \
    --enable-kvm \
    -smp "cpus=8" \
    -m 4G \
    -hda obsd.qcow2 \
    -nic user,hostfwd=tcp::10022-:22 \
    --nographic
