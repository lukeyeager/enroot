# Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.

# With help from investigation at https://stackoverflow.com/a/37867949/2404152
docker_ugly::import() (
    local orig_uri="$1"
    local filename="$2"

    local image=""
    local tag=""
    local user=""

    local reg_user="[[:alnum:]_.!~*\'()%\;:\&=+$,-]+"
    local reg_image="[[:lower:][:digit:]/.:_-]+"
    local reg_tag="[[:alnum:]._-]+"

    if [[ "${orig_uri}" =~ ^docker-ugly://((${reg_user})@)?(${reg_image})(:(${reg_tag}))?$ ]]; then
        user="${BASH_REMATCH[2]}"
        image="${BASH_REMATCH[3]}"
        tag="${BASH_REMATCH[5]}"
    else
        common::err "Invalid image reference: ${orig_uri}"
    fi

    # Rebuild URI
    local changed=0
    local enroot_uri="docker://"
    if [ -n "$user" ]; then enroot_uri="${enroot_uri}${user}@"; fi
    local registry_and_image="$image"
    if [[ "$image" =~ ^[^/]+[:.][^/]+/ ]]; then
        registry_and_image="${image/\//\#}"
        changed=1
    fi
    enroot_uri="${enroot_uri}${registry_and_image}"
    if [ -n "$tag" ]; then enroot_uri="${enroot_uri}:${tag}"; fi

    if [ "$changed" -ne 0 ]; then
        common::log INFO "Registry detected; changed URI to $enroot_uri"
    fi

    docker::import "$enroot_uri" "$filename"
)
