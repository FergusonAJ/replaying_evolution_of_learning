#!/bin/bash

NUM_REPS=50

## Run replays for all single mutations at the largest potentiating step 
#REPLAY_SEEDS="474 475"
REPLAY_SEEDS="475"
declare -a GENOME_MAP
GENOME_MAP[474]="wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wbOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wbOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wBOeNiORahjgohoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNecHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaFQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaNQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpsvGgfrFurGaaFQawlIPHOR wBOeNiORahjgrhoQmaFdjAbcdclExmzHoutOBxNJNeLHppGqhKpjqrutwovqalsKtBwlaIBaMkfIwpSrHFBbpHvGgfrFurGaaNQawlIPHOR "
GENOME_MAP[475]="yfCBsfLLCDAtJbRFkrynewLqleIcOtSzLSofcGOqcdRcLPMRbeHNJhmnBvdOhOHNGlHqpOPIaOSHbaPfqFaRoKCPAPbPijwgfzhsPpF yfCBsfLLCDAtJbRFkrynewLqleIcOtSzLSofcGOqcdRcLPMRbeHNJhmnBvdOhOHNGlHqpOPIaOSHbkPfqFaRdKCPAPbPijwgfzhsPpF "
declare -a DEPTH_MAP
DEPTH_MAP[474]="540"
DEPTH_MAP[475]="783"
    
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
