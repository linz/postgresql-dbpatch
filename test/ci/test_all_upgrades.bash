#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s failglob inherit_errexit

cd "$(dirname "$0")/../../"

#
# Versions/tags known to build
#
VER="1.0.0 1.0.1 1.1.0 1.3.0 1.4.0 1.5.0 1.6.0 1.7.0";

# Install all older versions
if [ -e .git/shallow ]
then
    git fetch --unshallow # in case this was a shallow copy
fi
git fetch --tags
git clone . older-versions
cd older-versions
for v in $VER; do
  echo "-------------------------------------"
  echo "Installing version $v"
  echo "-------------------------------------"
  git clean -dxf && git checkout "$v" && sudo env "PATH=$PATH" make install || exit 1
done;
cd ..
rm -rf older-versions;

# Test upgrade from all older versions
for v in $VER; do
  echo "-------------------------------------"
  echo "Checking upgrade from version $v"
  echo "-------------------------------------"
  make installcheck-upgrade PREPAREDB_UPGRADE_FROM="$v" || { cat regression.diffs; exit 1; }
done
