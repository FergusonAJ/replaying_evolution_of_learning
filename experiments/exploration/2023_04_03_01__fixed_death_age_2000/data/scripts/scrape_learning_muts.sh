#!/bin/bash

if [ ! $# -eq 2 ] 
then
    echo "Incorrect number of command line args: $#"
    echo "Expected 2:"
    echo "    1. The input directory"
    echo "    2. The output directory"
    exit 1
fi

INPUT_DIR=$1
OUTPUT_DIR=$2

OUTPUT_FILENAME=${OUTPUT_DIR}/combined_learning_summary.csv

FILENAMES=`ls ${INPUT_DIR}/learning_summary_*`

IS_STARTED=0

for FILENAME in ${FILENAMES} 
do
    if [ ${IS_STARTED} -eq 0 ]
    then
        echo "Copied file: ${FILENAME}"
        cp ${FILENAME} ${OUTPUT_FILENAME}
        IS_STARTED=1
    else
        echo "${FILENAME}"
        NUM_LINES=`wc -l ${FILENAME} | grep -oP "^\d+"`
        tail -n $(( ${NUM_LINES} - 1 )) ${FILENAME} >> ${OUTPUT_FILENAME}
    fi
done
