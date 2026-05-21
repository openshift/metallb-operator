#!/bin/bash

manifests/ocpcsv/align.sh
git diff --exit-code --quiet -I'^    createdAt: ' manifests/stable