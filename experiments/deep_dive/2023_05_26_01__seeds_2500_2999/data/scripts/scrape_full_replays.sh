#!/bin/bash

NUM_REPS=50

#REPLAY_SEEDS="108 183 206"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="2538 2488 2438 2388 2338"
#DEPTH_MAP[183]="713 663 613 563 513"
#DEPTH_MAP[206]="1810 1760 1710 1660 1610"

#REPLAY_SEEDS="108 183"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="2288 2238 2188 2138 2088 2038"
#DEPTH_MAP[183]="463 413 363 313 263 213"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1988 1938 1888 1838 1788 1738"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1688 1638 1588 1538 1488 1438"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1388 1338 1288 1238 1188 1138"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1088 1038 988 938 888 838"

REPLAY_SEEDS="108"
declare -a DEPTH_MAP
DEPTH_MAP[108]="788 738 688 638 588 538 488 438 388 338 288 238 188 138 88 38"
    
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
