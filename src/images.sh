#!/bin/bash
btrfs_path='/var/bocker'

function bocker_images() { #HELP List images:\nBOCKER images
  echo -e "IMAGE_ID\t\tSOURCE"
  for img in "$btrfs_path"/img_*; do
    img=$(basename "$img")
    echo -e "$img\t\t$(cat "$btrfs_path/$img/img.source")"
  done
}
