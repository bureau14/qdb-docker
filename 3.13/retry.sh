#!/usr/bin/env bash
TIMES=$1
shift;

while [[ $TIMES -ne 0 ]] && ! $@
do
    TIMES=$((TIMES-1))
done

if [[ $TIMES -eq 0 ]]
then
    exit -1
fi
