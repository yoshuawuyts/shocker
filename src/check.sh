#!/bin/sh

function bocker_check() {
  btrfs subvolume list "$btrfs_path" \
    | grep -qw "$1" && echo 0 || echo 1
}
