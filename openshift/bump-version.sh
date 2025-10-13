#!/bin/bash

# Script to automate MetalLB Operator version bumping
# Usage: ./bump-version.sh <new_version>
# Example: ./bump-version.sh 4.22

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 4.22"
    exit 1
fi

NEW_VERSION=$1

CSV_FILE="manifests/stable/metallb-operator.clusterserviceversion.yaml"

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: $CSV_FILE not found"
    exit 1
fi

CURRENT_VERSION=$(grep "containerImage: quay.io/openshift/origin-metallb-operator:" "$CSV_FILE" | sed -n 's/.*origin-metallb-operator:\([0-9.]*\).*/\1/p')

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not extract current version from $CSV_FILE"
    exit 1
fi

sed -i "s/openshift-${CURRENT_VERSION}/openshift-${NEW_VERSION}/g" .ci-operator.yaml
sed -i "s/openshift-${CURRENT_VERSION}/openshift-${NEW_VERSION}/g" Dockerfile.openshift
sed -i "s/ocp\/${CURRENT_VERSION}:/ocp\/${NEW_VERSION}:/g" Dockerfile.openshift
sed -i "s/v${CURRENT_VERSION}\"/v${NEW_VERSION}\"/g" bundle.Dockerfile
sed -i "s/metallb-operator.v${CURRENT_VERSION}/metallb-operator.v${NEW_VERSION}/g" manifests/metallb-operator.package.yaml
sed -i "s/:${CURRENT_VERSION}/:${NEW_VERSION}/g" manifests/stable/image-references
sed -i "s/:${CURRENT_VERSION}/:${NEW_VERSION}/g" "$CSV_FILE"
sed -i "s/v${CURRENT_VERSION}\\.0/v${NEW_VERSION}.0/g" "$CSV_FILE"
sed -i "s/<${CURRENT_VERSION}\\.0/<${NEW_VERSION}.0/g" "$CSV_FILE"

