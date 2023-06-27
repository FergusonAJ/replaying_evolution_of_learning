#!/bin/bash

NUM_REPS=50

#declare -a DEPTH_MAP
#REPLAY_SEEDS="21"
#DEPTH_MAP[21]="2366 2316 2266 2216 2166"

#REPLAY_SEEDS="21"
#declare -a DEPTH_MAP
#DEPTH_MAP[21]="2116 2066 2016 1966 1916 1866"

#REPLAY_SEEDS="21"
#declare -a DEPTH_MAP
#DEPTH_MAP[21]="1816 1766 1716 1666 1616 1566"

#REPLAY_SEEDS="21"
#declare -a DEPTH_MAP
#DEPTH_MAP[21]="1516 1466 1416 1366 1316 1266"

#REPLAY_SEEDS="21"
#declare -a DEPTH_MAP
#DEPTH_MAP[21]="1216 1166 1116 1066 1016 966"

REPLAY_SEEDS="21"
declare -a DEPTH_MAP
DEPTH_MAP[21]="916 866 816 766 716 666"
    
# Grab the experiment name
EXP_NAME=$(pwd | grep -oP "/\K[^/]+(?=/data|/data/scripts)")

# Grab global config variables
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

# Calculate directories to pass to R script
SCRATCH_REP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}/reps
OUTPUT_DIR=$(pwd | grep -oP ".+/${EXP_NAME}/data")
SCRIPT_DIR=${OUTPUT_DIR}/scripts

for REPLAY_SEED in ${REPLAY_SEEDS}
do
    echo "Starting seed: ${REPLAY_SEED}"
    for REPLAY_DEPTH in ${DEPTH_MAP[REPLAY_SEED]}
    do
        echo "  Depth: ${REPLAY_DEPTH}"
        REPLAY_SCRATCH_REP_DIR=${SCRATCH_REP_DIR}/${REPLAY_SEED}/full_replays/${REPLAY_DEPTH}
        REPLAY_OUTPUT_DIR=${OUTPUT_DIR}/reps/${REPLAY_SEED}/full_replays/${REPLAY_DEPTH}
        mkdir -p ${REPLAY_OUTPUT_DIR}
        echo ""
        echo "Pulling data from: ${REPLAY_SCRATCH_REP_DIR}"
        echo "Saving data to: ${REPLAY_OUTPUT_DIR}"
        echo ""
        Rscript ${SCRIPT_DIR}/combine_final_dominant_data.R ${REPLAY_SCRATCH_REP_DIR} ${REPLAY_OUTPUT_DIR} ${NUM_REPS}
    done
    echo "----------------"
done
