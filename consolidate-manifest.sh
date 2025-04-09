#!/bin/bash

set -e

check_if_variant_has_required_binaries() {
    local -n variant_binaries_ref=$1
    local -n required_binaries_ref=$2

    for req_bin in "${required_binaries_ref[@]}"; do
        found=0
        for var_bin in "${variant_binaries_ref[@]}"; do
            if [[ "$var_bin" == "$req_bin" ]]; then
                found=1
                break
            fi
        done

        if [[ $found -eq 0 ]]; then
            return 1
        fi
    done
    return 0
}


consolidate_manifests() {
    local config_file=$1

    # with jq we can parse json files and extract the values we need
    # mapfile maps the input to an array
    mapfile -t variants < <(jq -r '.variants[]' "$config_file")
    mapfile -t images < <(jq -r '.components | keys[]' "$config_file")
    mapfile -t versions < <(jq -r '.versions | keys[]' "$config_file")

    for image in "${images[@]}"; do
        mapfile -t required_binaries < <(jq -r ".components[\"$image\"][]" "$config_file")
        for version in "${versions[@]}"; do
            echo $version
            mapfile -t tags < <(jq -r ".versions[\"$version\"][\"tags\"][]" "$config_file")
            for tag in "${tags[@]}"; do
                echo "Consolidating docker image: $image with tag: $tag"
                manifest_images=""
                for variant in "${variants[@]}"; do
                    if [[ "$variant" == "core2" ]]; then
                        # we skip core2 variant from the manifest
                        # core2 is meant for very old hosts, docker won't see difference between core2 and haswell
                        # its better to not include it in the manifest
                        echo "Skipping $variant variant for $image"
                        continue
                    fi

                    # we need to check if the variant exists for the image before appending it to manifest
                    # for e.g aarch64 for 3.13 doesn't have rest api image
                    # variant exists if it has sources for all required binaries for the image 
                    mapfile -t variant_binaries < <(jq -r ".versions[\"$version\"][\"$variant\"] | keys[]" "$config_file")
                    if ! check_if_variant_has_required_binaries variant_binaries required_binaries; then
                        echo "$variant image for $image with tag $tag doesn't exist"
                        continue
                    fi


                    echo "Found $variant image for $image with tag: $tag"

                    if [[ "$variant" == "default" ]]; then
                        manifest_images="${manifest_images} --amend bureau14/${image}:${tag}"
                    else
                        manifest_images="${manifest_images} --amend bureau14/${image}:${tag}-${variant}"
                    fi
                done
                    
                delete_command="docker manifest rm bureau14/${image}:${tag}"
                create_command="docker manifest create bureau14/${image}:${tag} ${manifest_images}"
                push_command="docker manifest push bureau14/${image}:${tag}"

                for command in "$delete_command" "$create_command" "$push_command"; do
                    echo "Executing command: $command"
                    # eval "$command"
                done
            done
        done
    done

    echo "Manifest consolidation completed successfully."
}

CONFIG_FILE=${1:-"./config.json"}
consolidate_manifests $CONFIG_FILE