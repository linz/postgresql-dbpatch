#!/bin/sh

cd `dirname $0`/../../

#
# Versions/tags known to build
#
VER="1.0.0 1.0.1";

# Install all older versions
test .git/shallow && git fetch --unshallow # in case this was a shallow copy
git fetch --tags
git clone . older-versions
cd older-versions
for v in $VER; do
  echo "-------------------------------------"
  echo "Installing version $v"
  echo "-------------------------------------"
  git clean -dxf && git checkout $v && sudo env "PATH=$PATH" make install || exit 1
done;
cd ..
rm -rf older-versions;

# Test upgrade from all older versions
for v in $VER; do
  echo "-------------------------------------"
  echo "Checking upgrade from version $v"
  echo "-------------------------------------"
  make installcheck-upgrade PREPAREDB_UPGRADE_FROM=$v || { cat regression.diffs; exit 1; }
done

