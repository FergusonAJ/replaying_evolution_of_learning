#!/bin/bash

IS_REPLAY=1
REPLAY_SEED=7
#REPLAY_DEPTH=16  # Scraped 
#REPLAY_DEPTH=33  # Scraped
#REPLAY_DEPTH=49  # Scraped
#REPLAY_DEPTH=66  # Scraped
#REPLAY_DEPTH=82  # Scraped 
#REPLAY_DEPTH=99  # Scraped
#REPLAY_DEPTH=116 # Scraped 
#REPLAY_DEPTH=133 # Scraped
#REPLAY_DEPTH=149 # Scraped
#REPLAY_DEPTH=166 # Scraped
REPLAY_DEPTH=182 # Scraped
#REPLAY_DEPTH=199 # Scraped (100% learning)
#REPLAY_DEPTH=266 # Scraped
#REPLAY_DEPTH=333 # Scraped
#REPLAY_DEPTH=399 # Scraped

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
