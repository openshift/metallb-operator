#!/bin/bash

export OPERATOR_SDK_VERSION=v1.22.2
make operator-sdk

mkdir -p _cache/bundle/manifests
cp manifests/stable/*.yaml _cache/bundle/manifests
cp -r bundle/metadata _cache/bundle/
operator-sdk bundle validate _cache/bundle

echo "sleeping"
sleep 3h
