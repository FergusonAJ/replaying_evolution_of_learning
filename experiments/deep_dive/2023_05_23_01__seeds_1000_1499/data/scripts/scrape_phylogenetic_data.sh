#!/bin/bash

# Grab the experiment name
EXP_NAME=$(pwd | grep -oP "/\K[^/]+(?=/data|/data/scripts)")

# Grab global config variables
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

# Calculate directories to pass to R script
SCRATCH_REP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}/reps
OUTPUT_DIR=$(pwd | grep -oP ".+/${EXP_NAME}/data")
FILENAME=${OUTPUT_DIR}/combined_final_phylogenetic_data.csv

echo ""
echo "Pulling data from: ${SCRATCH_REP_DIR}"
echo "Saving data to: ${OUTPUT_DIR}"
echo ""

HEADER=$(head -n 1 ${SCRATCH_REP_DIR}/1/phylo/phylogenetic_data.csv)
echo "${HEADER}, seed" > ${FILENAME}
DIR_LIST=$(ls ${SCRATCH_REP_DIR})
for DIR_NAME in ${DIR_LIST}
do
    INPUT_FILENAME=${SCRATCH_REP_DIR}/${DIR_NAME}/phylo/phylogenetic_data.csv
    if [ -e ${INPUT_FILENAME} ]
    then
        echo ${DIR_NAME}
        LINE=$(tail -n 1 ${INPUT_FILENAME})
        echo "${LINE}, ${DIR_NAME}" >> ${FILENAME}
    else
        echo "Skipping: ${DIR_NAME}, not found"
    fi
done





