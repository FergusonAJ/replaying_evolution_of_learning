#!/bin/bash

IS_REPLAY=0
    
# Grab the experiment name
EXP_NAME=$(pwd | grep -oP "/\K[^/]+(?=/data|/data/scripts)")

# Grab global config variables
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

# Calculate directories to pass to R script
SCRATCH_REP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}/reps
OUTPUT_DIR=$(pwd | grep -oP ".+/${EXP_NAME}/data")
SCRIPT_DIR=${OUTPUT_DIR}/scripts

if [ $IS_REPLAY -gt 0 ]
then
    SCRATCH_REP_DIR=${SCRATCH_REP_DIR}/${REPLAY_SEED}/replays/${REPLAY_DEPTH}
    OUTPUT_DIR=${OUTPUT_DIR}/reps/${REPLAY_SEED}/replays/${REPLAY_DEPTH}
    mkdir -p ${OUTPUT_DIR}
fi

echo ""
echo "Pulling data from: ${SCRATCH_REP_DIR}"
echo "Saving data to: ${OUTPUT_DIR}"
echo ""
Rscript ${SCRIPT_DIR}/combine_final_dominant_data.R ${SCRATCH_REP_DIR} ${OUTPUT_DIR}
