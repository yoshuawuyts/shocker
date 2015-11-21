#!/bin/bash

# display a help message
bocker_help() {
  cat << USAGE
  Usage: shocker [options] <command>

  Commands:
    commit, exec, help, image, init,
    kill, logs, ps, pull, rm, run,
    spawn

  Options:
    -h, --help     output usage information
    -v, --version  output version information

  Examples:
    shocker init   # create a new container
    shocker exec   # run a command in shocker
USAGE
}
