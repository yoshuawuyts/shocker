#!/bin/bash
btrfs_path='/var/bocker'

#HELP Create an image from a directory:\nBOCKER init <directory>
function bocker_init() {
  uuid="img_$(shuf -i 42002-42254 -n 1)"
  if [[ -d "$1" ]]; then
    [[ "$(bocker_check "$uuid")" == 0 ]] && bocker_run "$@"
    btrfs subvolume create "$btrfs_path/$uuid" > /dev/null
    cp -rf --reflink=auto "$1"/* "$btrfs_path/$uuid" > /dev/null
    [[ ! -f "$btrfs_path/$uuid"/img.source ]] && echo "$1" > "$btrfs_path/$uuid"/img.source
    echo "Created: $uuid"
  else
    echo "No directory named '$1' exists"
  fi
}
