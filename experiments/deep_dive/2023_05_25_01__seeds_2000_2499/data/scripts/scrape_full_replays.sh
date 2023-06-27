#!/bin/bash

NUM_REPS=50

#REPLAY_SEEDS="95 186 208 210 409"
#declare -a DEPTH_MAP
#DEPTH_MAP[95]="1392 1342 1292 1242 1192"
#DEPTH_MAP[186]="1696 1646 1596 1546 1496"
#DEPTH_MAP[208]="559 509 459 409 359"
#DEPTH_MAP[210]="2167 2117 2067 2017 1967"
#DEPTH_MAP[409]="788 738 688 638 588"

#REPLAY_SEEDS="186 208 409"
#declare -a DEPTH_MAP
#DEPTH_MAP[186]="1446 1396 1346 1296 1246 1196"
#DEPTH_MAP[208]="309 259 209 159 109 59"
#DEPTH_MAP[409]="538 488 438 388 338 288"

#REPLAY_SEEDS="186"
#declare -a DEPTH_MAP
#DEPTH_MAP[186]="1146 1096 1046 996 946 896"

REPLAY_SEEDS="186"
declare -a DEPTH_MAP
DEPTH_MAP[186]="846 796 746 696 646 596"
    
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
