#!/bin/bash

set -e

config_file=${1:-"config.json"}
versions=($(find . -mindepth 1 -maxdepth 1 -type d -name '[0-9].*' | sed 's|^\./||'))

for version in "${versions[@]}"; do
    echo "Processing version: $version"

    # Tags for version from config file
    mapfile -t tags < <(jq -r ".versions[\"$version\"][\"tags\"][]" "$config_file")

    # Hashmap of images and available architectures for manifest
    declare -A image_arch_map

    # Find images for each architecture and add them to image_arch_map
    version_subdirs=($(find "$version" -mindepth 1 -maxdepth 1 -type d))
    for arch in ${version_subdirs[@]}; do
        arch_name=$(basename "$arch")

        if [[ $arch_name == "core2" ]]; then
            echo "Skipping $arch_name from manifest creation"
            continue
        fi

        arch_subdirs=($(find "$arch" -mindepth 1 -maxdepth 1 -type d))
        for image in ${arch_subdirs[@]}; do
            image_name=$(basename "$image")
            image_arch_map["$image_name"]+="$arch_name "
        done
    done

    # Create manifest for each image:tag
    for image in "${!image_arch_map[@]}"; do
        echo "Creating manifest for image: $image"

        for tag in "${tags[@]}"; do
            full_tag="bureau14/${image}:${tag}"
            
            echo Executing: docker manifest rm "$full_tag"
            docker manifest rm "$full_tag" || true

            manifest_images=""
            for arch in ${image_arch_map["$image"]}; do
                manifest_images+=" --amend bureau14/$image:$tag-$arch "
            done

            echo Executing: docker manifest create "$full_tag" ${manifest_images}
            docker manifest create "$full_tag" ${manifest_images}

            echo Executing: docker manifest push "$full_tag"
            docker manifest push "$full_tag"
        done
    done

    unset image_arch_map
done
