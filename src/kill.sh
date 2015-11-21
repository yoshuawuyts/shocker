#!/usr/bin/env bash

function bocker_kill() { #HELP Kill a running container:\nBOCKER kill <container_id> [<signal>]
  bocker_exec "$1" /bin/kill -s "${2:-SIGTERM}" -- -1
}
