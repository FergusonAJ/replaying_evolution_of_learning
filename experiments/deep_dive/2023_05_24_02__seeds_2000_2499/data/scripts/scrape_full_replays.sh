#!/bin/bash

NUM_REPS=50

#REPLAY_SEEDS="63 162 188 223 237 331 335 336"
#declare -a DEPTH_MAP
#DEPTH_MAP[63]="1774 1724 1674 1624 1574"
#DEPTH_MAP[162]="2149 2099 2049 1999 1949"
#DEPTH_MAP[188]="1049 999 949 899 849"
#DEPTH_MAP[223]="2558 2508 2458 2408 2358"
#DEPTH_MAP[237]="928 878 828 778 728"
#DEPTH_MAP[331]="941 891 841 791 741"
#DEPTH_MAP[335]="1726 1676 1626 1576 1526"
#DEPTH_MAP[336]="983 933 883 833 783"

#REPLAY_SEEDS="223 331 335 336"
#declare -a DEPTH_MAP
#DEPTH_MAP[223]="2308 2258 2208 2158 2108 2058"
#DEPTH_MAP[331]="691 641 591 541 491 441"
#DEPTH_MAP[335]="1476 1426 1376 1326 1276 1226"
#DEPTH_MAP[336]="733 683 633 583 533 483"

REPLAY_SEEDS="223 331 335"
declare -a DEPTH_MAP
DEPTH_MAP[223]="2008 1958 1908 1858 1808 1758"
DEPTH_MAP[331]="391 341 291 241 191 141"
DEPTH_MAP[335]="1176 1126 1076 1026 976 926"

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
