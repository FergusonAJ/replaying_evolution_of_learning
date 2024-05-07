#!/bin/bash

NUM_REPS=50

## Run replays for all single mutations at the largest potentiating step 
REPLAY_SEEDS="184 223 278 485"
declare -a GENOME_MAP
GENOME_MAP[184]="lsAzoiKhyRzFfBlomNBnDnzyjHBcPdGcPIdRFHEBkyvtMpJrHNCGqLCamBvIFHjbkHGrrhQlAczNkkdkAcqwyjFtmOLSmEpkGPezxLnyp lsAzoiKhyRQFfBlomNBnDnzyjHBcPDGcPIdRFHEBkyvtMpJrHNCGqLCamBvIFHjbkHGrrhQlAczNkkdkAcqwyjFtmOLSmEpkGPezxLnyp lsAzoiKhyRzFfBlomNBnDnzyjHBcPDGcPIdRFHEBkyvtMpJrHNCGqLCamBvIFHjbkHGrrhQlAczNkkdkAcqwyjFtmOLSmEpkGPezxLnyp lsAzoiKhyRQFfBlomNBnDnzyjHBcPdGcPIdRqHEBkyvtMpJrHNCGqLCamBvIFHjbkHGrrhQlAczNkkdkAcqwyjFtmOLSmEpkGPezxLnyp lsAzoiKhyRzFfBlomNBnDnzyjHBcPdGcPIdRqHEBkyvtMpJrHNCGqLCamBvIFHjbkHGrrhQlAczNkkdkAcqwyjFtmOLSmEpkGPezxLnyp lsAzoiKhyRQFfBlomNBnDnzyjHBcPDGcPIdRqHEBkyvtMpJrHNCGqLCamBvIFHjbkHGrrhQlAczNkkdkAcqwyjFtmOLSmEpkGPezxLnyp "
GENOME_MAP[223]="xpPmOhOLHjObwrROzGprHFdfNJNmSEbBkPleKSpLCFuFjaSmrDlDxjkawQQIEHxSthILszBsKxjSfnNmuffDpKCxxnLrtueLeeQ xpPmOFOLHjObwrROzGprHFdfNJNmSEbBkPleKSpLCFuFjaSmrDlDxjkawQQIcHxSthILszBsKxjSfnNmuffDpKCxxnLrtueLeeQ "
GENOME_MAP[278]="qHbOLHOqPIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnSknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfsnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGOiPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo qHbOLHOqPIHNJoqKGqjGhGKdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo qHbOLHOqMIHNJoqKGqjGhGOdPJqMNpAnnxeSAylzmuJhErMClOlAijQaBxHxDhnsaDOsxeQrKhkghGjrKFBsLohBcfMnaknhiLzxoANo "
GENOME_MAP[485]="DkOLaOweLGlibdjCMrFMRdRnfDwqKDGJgoOqaCKgQOlwhjRwzKvLhemePfpHPIvhkxRLGHrNJShBKHjqgtADkhvaGhNJnLHzCblueEA DkpLaOQeLGlibdjCMrFMRdRnfDwqKDGJgoOqaCKgQOlwhjRwzKvLhemePfpHPIvhkxRLGHrNJShBKHjqgtADkhvaGhNJnLHzCblueEA DkOLaOQeLGlibdjCMrFMRdRnfDwqKDGJgoOqaCKgQOlwhjRwzKvLhemePfpHPIvhkxRLGHrNJShBKHjqgtADkhvaGhNJnLHzCblueEA DkpLaOweLGlibdjCMrFMRdRnfDwqKDGJgoOqaCKgQOlwhjRwzKvLhemePfpHPIfhkxRLGHrNJShBKHjqgtADkhvaGhNJnLHzCblueEA DkOLaOweLGlibdjCMrFMRdRnfDwqKDGJgoOqaCKgQOlwhjRwzKvLhemePfpHPIfhkxRLGHrNJShBKHjqgtADkhvaGhNJnLHzCblueEA DkpLaOQeLGlibdjCMrFMRdRnfDwqKDGJgoOqaCKgQOlwhjRwzKvLhemePfpHPIfhkxRLGHrNJShBKHjqgtADkhvaGhNJnLHzCblueEA "
declare -a DEPTH_MAP
DEPTH_MAP[184]="920"
DEPTH_MAP[223]="387"
DEPTH_MAP[278]="1205"
DEPTH_MAP[485]="1317"
    
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
    GENOME_IDX=0
    REPLAY_DEPTH=${DEPTH_MAP[REPLAY_SEED]}
    for START_GENOME in ${GENOME_MAP[REPLAY_SEED]}
    do
        echo "  Depth: ${REPLAY_DEPTH}"
        REPLAY_SCRATCH_REP_DIR=${SCRATCH_REP_DIR}/${REPLAY_SEED}/mut_splits/${GENOME_IDX}
        REPLAY_OUTPUT_DIR=${OUTPUT_DIR}/reps/${REPLAY_SEED}/mut_splits/${GENOME_IDX}
        mkdir -p ${REPLAY_OUTPUT_DIR}
        echo ""
        echo "Pulling data from: ${REPLAY_SCRATCH_REP_DIR}"
        echo "Saving data to: ${REPLAY_OUTPUT_DIR}"
        echo ""
        Rscript ${SCRIPT_DIR}/combine_final_dominant_data.R ${REPLAY_SCRATCH_REP_DIR} ${REPLAY_OUTPUT_DIR} ${NUM_REPS}
        GENOME_IDX=$(( GENOME_IDX + 1 ))
    done
    echo "----------------"
done