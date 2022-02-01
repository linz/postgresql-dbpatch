#!/usr/bin/env bash

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s failglob inherit_errexit

# Versions/tags known to build
git tag --list '[0-9]*.[0-9]*.[0-9]*' | grep --fixed-strings --invert-match --line-regexp --regexp=1.2.0
