#!/bin/bash
btrfs_path='/var/bocker'

function bocker_exec() { #HELP Execute a command in a running container:\nBOCKER exec <container_id> <command>
  [[ "$(bocker_check "$1")" == 1 ]] && echo "No container named '$1' exists" && exit 1
  cid="$(ps ao ppid,pid | awk -v ppid=$(pgrep -f "unshare.*$1") '$1 == ppid {print $2}')"
  [[ ! "$cid" =~ ^\ *[0-9]+$ ]] && echo "Container '$1' exists but is not running" && exit 1
  nsenter -t "$cid" -m -u -i -n -p chroot "$btrfs_path/$1" "${@:2}"
}
