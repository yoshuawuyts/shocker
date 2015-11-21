#!bin/bash
btrfs_path='/var/bocker'

function bocker_ps() { #HELP List containers:\nBOCKER ps
  echo -e "CONTAINER_ID\t\tCOMMAND"
  for ps in "$btrfs_path"/ps_*; do
    ps=$(basename "$ps")
    echo -e "$ps\t\t$(cat "$btrfs_path/$ps/$ps.cmd")"
  done
}
