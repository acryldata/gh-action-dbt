#!/bin/bash

set -euxo pipefail

export DBT_PROFILES_DIR=${GITHUB_ACTION_PATH}/fake-dbt-profile

# Check dbt installation.
cd ${DBT_PROJECT_FOLDER}
dbt --version

# Install acryl-datahub package.
pip install acryl-datahub==0.10.1.2rc8
pip cache remove 'acryl*'

# Generate the previous manifest.
git checkout ${GITHUB_BASE_REF}
dbt ls
cp -r target target-previous
git checkout -

# Run impact analysis script.
DBT_ARTIFACT_STATE_PATH=target-previous python ${GITHUB_ACTION_PATH}/impact_analysis.py
cat impact_analysis.md

# Output a multiline string to an output parameter.
# Technique from https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)
echo "IMPACT_ANALYSIS_MD<<$EOF" >> $GITHUB_OUTPUT
cat impact_analysis.md >> $GITHUB_OUTPUT
echo "$EOF" >> $GITHUB_OUTPUT