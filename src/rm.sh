#!/bin/bash

btrfs_path='/var/bocker' && cgroups='cpu,cpuacct,memory'

function bocker_rm() { #HELP Delete an image or container:\nBOCKER rm <image_id or container_id>
  [[ "$(bocker_check "$1")" == 1 ]] && echo "No container named '$1' exists" && exit 1
  btrfs subvolume delete "$btrfs_path/$1" > /dev/null
  cgdelete -g "$cgroups:/$1" &> /dev/null || true
  echo "Removed: $1"
}
