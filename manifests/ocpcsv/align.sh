#!/bin/bash

export OPERATOR_SDK=_cache/operator-sdk
make operator-sdk
export KUSTOMIZE=_cache/kustomize
make kustomize
VERSION="4.19"
CSV_VERSION="$VERSION.0"


sed -i 's/quay.io\/openshift\/origin-metallb:.*$/quay.io\/openshift\/origin-metallb:'"$VERSION"'/g' manifests/ocpcsv/controller-webhook-patch.yaml
sed -i 's/quay.io\/openshift\/origin-metallb:.*$/quay.io\/openshift\/origin-metallb:'"$VERSION"'/g' manifests/ocpcsv/ocpvariables.yaml
sed -i 's/quay.io\/openshift\/origin-metallb-frr:.*$/quay.io\/openshift\/origin-metallb-frr:'"$VERSION"'/g' manifests/ocpcsv/ocpvariables.yaml
sed -i 's/quay.io\/openshift\/origin-kube-rbac-proxy:.*$/quay.io\/openshift\/origin-kube-rbac-proxy:'"$VERSION"'/g' manifests/ocpcsv/ocpvariables.yaml
sed -i 's/quay.io\/openshift\/origin-metallb-operator:.*$/quay.io\/openshift\/origin-metallb-operator:'"$VERSION"'/g' manifests/ocpcsv/ocpvariables.yaml

sed -i 's/quay.io\/openshift\/origin-metallb:.*$/quay.io\/openshift\/origin-metallb:'"$VERSION"'/g' manifests/stable/image-references
sed -i 's/quay.io\/openshift\/origin-metallb-frr:.*$/quay.io\/openshift\/origin-metallb-frr:'"$VERSION"'/g' manifests/stable/image-references
sed -i 's/quay.io\/openshift\/origin-kube-rbac-proxy:.*$/quay.io\/openshift\/origin-kube-rbac-proxy:'"$VERSION"'/g' manifests/stable/image-references
sed -i 's/quay.io\/openshift\/origin-metallb-operator:.*$/quay.io\/openshift\/origin-metallb-operator:'"$VERSION"'/g' manifests/stable/image-references

sed -i 's/quay.io\/openshift\/origin-metallb-operator:.*$/quay.io\/openshift\/origin-metallb-operator:'"$VERSION"'/g' manifests/ocpcsv/bases/metallb-operator.clusterserviceversion.yaml
sed -i 's/olm-status-descriptors: metallb-operator.*$/olm-status-descriptors: metallb-operator.v'"$CSV_VERSION"'/g' manifests/ocpcsv/bases/metallb-operator.clusterserviceversion.yaml
sed -i 's/>=4\.8\.0 <.*$/>=4\.8\.0 <'"$CSV_VERSION"'"/g' manifests/ocpcsv/bases/metallb-operator.clusterserviceversion.yaml


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
sed -i 's/LABEL com.redhat.openshift.versions=.*$/LABEL com.redhat.openshift.versions="v'"$VERSION"'"/g' bundle.Dockerfile
sed -i 's/currentCSV: metallb-operator.*$/currentCSV: metallb-operator\.v'"$CSV_VERSION"'/g' manifests/metallb-operator.package.yaml
