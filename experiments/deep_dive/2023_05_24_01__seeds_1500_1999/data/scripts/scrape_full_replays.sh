#!/bin/bash

NUM_REPS=50

#REPLAY_SEEDS="203 238 474 475"
#declare -a DEPTH_MAP
#DEPTH_MAP[203]="452 402 352 302 252"
#DEPTH_MAP[238]="1084 1034 984 934 884"
#DEPTH_MAP[474]="1435 1385 1335 1285 1235"
#DEPTH_MAP[475]="938 888 838 788 738"

#REPLAY_SEEDS="474 475"
#declare -a DEPTH_MAP
#DEPTH_MAP[474]="1185 1135 1085 1035 985 935"
#DEPTH_MAP[475]="688 638 588 538 488 438"

#REPLAY_SEEDS="474"
#declare -a DEPTH_MAP
#DEPTH_MAP[474]="885 835 785 735 685 635"

REPLAY_SEEDS="474"
declare -a DEPTH_MAP
DEPTH_MAP[474]="585 535 485 435 385 335"
    
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
