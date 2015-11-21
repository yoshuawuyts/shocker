#!/usr/bin/env bash
btrfs_path='/var/bocker'

function bocker_logs() { #HELP View logs from a container:\nBOCKER logs <container_id>
  [[ "$(bocker_check "$1")" == 1 ]] && echo "No container named '$1' exists" && exit 1
  cat "$btrfs_path/$1/$1.log"
}
