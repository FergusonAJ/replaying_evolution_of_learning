#!/bin/bash

# Grab the experiment name
EXP_NAME=$(pwd | grep -oP "/\K[^/]+(?=/data|/data/scripts)")

# Grab global config variables
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

# Calculate directories to pass to R script
SCRATCH_REP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}/reps
OUTPUT_DIR=$(pwd | grep -oP ".+/${EXP_NAME}/data")

echo ""
echo "Pulling data from: ${SCRATCH_REP_DIR}"
echo "Saving data to: ${OUTPUT_DIR}"
echo ""
Rscript ${OUTPUT_DIR}/scripts/combine_final_dominant_data.R ${SCRATCH_REP_DIR} ${OUTPUT_DIR}
