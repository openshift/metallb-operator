#!/bin/bash

make operator-sdk

mkdir -p _cache/bundle/manifests
cp manifests/stable/*.yaml _cache/bundle/manifests
cp -r bundle/metadata _cache/bundle/
_cache/operator-sdk bundle validate _cache/bundle