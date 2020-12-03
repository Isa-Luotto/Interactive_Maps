#!/bin/sh

set -e

[ -z "${GITHUB_PAT}" ] && exit 0
[ "${TRAVIS_BRANCH}" != "master" ] && exit 0

git config --global user.email "Isa.Luotto@gmail.com"
git config --global user.name "Isa.Luotto"

