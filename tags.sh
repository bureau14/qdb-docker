#!/bin/bash

TAGS=("3.2.0" "3.2" "nightly")

# print_tags: Prints the tags separated by a ','
function print_tags {
    echo -n "tags: "
    local sep=""
    for tag in ${TAGS[@]}; do
        printf "%s%s" $sep $tag
        sep=","
    done
    echo ""
}
