#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s failglob inherit_errexit

project_root="$(dirname "$0")/../.."

#
# Versions/tags known to build
#
versions=(
    '1.0.0'
    '1.0.1'
    '1.1.0'
    '1.3.0'
    '1.4.0'
    '1.5.0'
    '1.6.0'
    '1.7.0'
)

# Install all older versions
work_directory="$(mktemp --directory)"
git clone "$project_root" "$work_directory"
for v in "${versions[@]}"
do
    echo "-------------------------------------"
    echo "Installing version $v"
    echo "-------------------------------------"
    git -C "$work_directory" clean -dxf && git -C "$work_directory" checkout "$v" && sudo env "PATH=$PATH" make -C "$work_directory" install
done
rm -rf "$work_directory"

# Test upgrade from all older versions
for v in "${versions[@]}"
do
    echo "-------------------------------------"
    echo "Checking upgrade from version $v"
    echo "-------------------------------------"
    if ! make -C "$work_directory" installcheck-upgrade PREPAREDB_UPGRADE_FROM="$v"
    then
        cat regression.diffs
        exit 1
    fi
done
