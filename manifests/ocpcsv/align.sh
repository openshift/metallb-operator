#!/bin/bash

export OPERATOR_SDK=_cache/operator-sdk
make operator-sdk
export KUSTOMIZE=_cache/kustomize
make kustomize
CSV_VERSION=4.14.0

# we need to save and restore as operatorsdk works with the local bundle.Dockerfile

mv bundle.Dockerfile bundle.Dockerfile_orig
rm -rf _cache/ocpmanifests

$OPERATOR_SDK generate kustomize manifests --interactive=false -q
$KUSTOMIZE build manifests/ocpcsv | $OPERATOR_SDK generate bundle --output-dir _cache/ocpmanifests -q --overwrite --version $CSV_VERSION --extra-service-accounts "controller,speaker"
$OPERATOR_SDK bundle validate ./bundle
rm manifests/stable/*.yaml
cp _cache/ocpmanifests/manifests/*.yaml manifests/stable/
#these were present and are not being added by kustomize
cp manifests/ocpcsv/bases/metallb-manager-role_rbac.authorization.k8s.io_v1_role.yaml manifests/stable/
cp manifests/ocpcsv/bases/metallb-manager-rolebinding_rbac.authorization.k8s.io_v1_rolebinding.yaml manifests/stable/
cp manifests/ocpcsv/bases/prometheus-k8s_rbac.authorization.k8s.io_v1_role.yaml manifests/stable/
cp manifests/ocpcsv/bases/prometheus-k8s_rbac.authorization.k8s.io_v1_rolebinding.yaml manifests/stable/

mv bundle.Dockerfile_orig bundle.Dockerfile
