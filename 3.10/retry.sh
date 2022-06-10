#!/usr/bin/env bash

TIMES=$1
shift;

COMMAND="/bin/bash -c '$@'"

while [[ $TIMES -ne 0 ]] && ! /usr/bin/env bash -c "${COMMAND[@]}"
do
    TIMES=$((TIMES-1))
    sleep 1
done

if [[ $TIMES -eq 0 ]]
then
    exit -1
fi
