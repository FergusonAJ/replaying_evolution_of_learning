#!/bin/bash

NUM_REPS=50

#REPLAY_SEEDS="332 426 434 487"
#declare -a DEPTH_MAP
#DEPTH_MAP[332]="1600 1550 1500 1450 1400"
#DEPTH_MAP[426]="1324 1274 1224 1174 1124"
#DEPTH_MAP[434]="2016 1966 1916 1866 1816"
#DEPTH_MAP[487]="1038 988 938 888 838"

#REPLAY_SEEDS="426 434"
#declare -a DEPTH_MAP
#DEPTH_MAP[426]="1324"
#DEPTH_MAP[434]="2016 1966 1916"

#REPLAY_SEEDS="426 434 487"
#declare -a DEPTH_MAP
#DEPTH_MAP[426]="1174 1124 1074 1024 974 924"
#DEPTH_MAP[434]="1766 1716 1666 1616 1566 1516"
#DEPTH_MAP[487]="788 738 688 638 588 538"

#REPLAY_SEEDS="332"
#declare -a DEPTH_MAP
#DEPTH_MAP[332]="1600 1550 1500 1450 1400"

#REPLAY_SEEDS="426 434"
#declare -a DEPTH_MAP
#DEPTH_MAP[426]="874 824 774 724 674 624"
#DEPTH_MAP[434]="1466 1416 1366 1316 1266 1216"

#REPLAY_SEEDS="332 426 434"
#declare -a DEPTH_MAP
#DEPTH_MAP[332]="1350 1300 1250 1200 1150 1100"
#DEPTH_MAP[426]="574 524 474 424 374 324"
#DEPTH_MAP[434]="1166 1116 1066 1016 966 916"

REPLAY_SEEDS="434"
declare -a DEPTH_MAP
DEPTH_MAP[434]="866 816 766 716 666 616"
    
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
