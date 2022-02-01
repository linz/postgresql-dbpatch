#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s failglob inherit_errexit

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$(dirname "$script_dir")")"

mapfile -t versions < <("${script_dir}/get_versions.bash")

# Install all older versions
trap 'rm -r "$work_directory"' EXIT
work_directory="$(mktemp --directory)"
git clone "$project_root" "$work_directory"
for version in "${versions[@]}"
do
    echo "-------------------------------------"
    echo "Installing version $version"
    echo "-------------------------------------"
    git -C "$work_directory" clean -dx --force
    git -C "$work_directory" checkout "$version"
    make --directory="$work_directory" PREFIX="$(mktemp --directory)" install
done

# Test upgrade from all older versions
for version in "${versions[@]}"
do
    echo "-------------------------------------"
    echo "Checking upgrade from version $version"
    echo "-------------------------------------"
    if ! make --directory="$work_directory" installcheck-upgrade PREPAREDB_UPGRADE_FROM="$version"
    then
        cat regression.diffs
        exit 1
    fi
done
