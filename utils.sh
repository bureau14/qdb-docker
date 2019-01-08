#!/bin/bash

function join_by { local IFS="$1"; shift; echo "$*"; }

function exists(){
  if [ "$2" != in ]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi
  eval '[ ${'$3'[$1]+muahaha} ]'
}
