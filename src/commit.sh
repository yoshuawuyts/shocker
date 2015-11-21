#!/bin/bash
btrfs_path='/var/bocker'

function bocker_commit() { #HELP Commit a container to an image:\nBOCKER commit <container_id> <image_id>
  [[ "$(bocker_check "$1")" == 1 ]] && echo "No container named '$1' exists" && exit 1
  [[ "$(bocker_check "$2")" == 1 ]] && echo "No image named '$2' exists" && exit 1
  bocker_rm "$2" && btrfs subvolume snapshot "$btrfs_path/$1" "$btrfs_path/$2" > /dev/null
  echo "Created: $2"
}
