#!/bin/bash

if [ ! $# -eq 2 ]
then
    echo "Incorrect number of command line args: $#"
    echo "Expected 2:"
    echo "    1. The seed of the replicate"
    echo "    2. The depth to process"
    exit 1
fi

SEED=$1
DEPTH=$2
echo "Processing depth ${DEPTH} from seed ${SEED}"

JOB_DIR=../../slurm/jobs
LOCAL_SEED=`cat random_seed.txt`

SEED_DATA_DIR=data/${SEED}/local_seed_${LOCAL_SEED}

mkdir -p ${SEED_DATA_DIR}
mkdir -p ${SEED_DATA_DIR}/orgs
mkdir -p ${SEED_DATA_DIR}/trace_source
mkdir -p ${SEED_DATA_DIR}/trace_images
mkdir -p ${SEED_DATA_DIR}/trace_grids
mkdir -p ${SEED_DATA_DIR}/fitness
mkdir -p ${SEED_DATA_DIR}/doors_images

# Prepare the organism
GENOME=`Rscript get_genome.R ${SEED} ${DEPTH}`
python3 ./shared_files/genome_conversion.py -c ${GENOME} final_dominant.org inst_set_output.txt
cp final_dominant.org ${SEED_DATA_DIR}/orgs/${DEPTH}.org

# Run the MABE analysis
./run_job.sb -m -l

# Run secondary scripts
./scrape_trace.sh
./draw_trace.sh

# Organize data
mv single_org_fitness.csv ${SEED_DATA_DIR}/fitness/${DEPTH}.csv
mv trace.txt ${SEED_DATA_DIR}/trace_source/${DEPTH}.txt
mv trace.png ${SEED_DATA_DIR}/trace_images/${DEPTH}.png
mv trace.csv ${SEED_DATA_DIR}/trace_grids/${DEPTH}.csv
mv out.png ${SEED_DATA_DIR}/doors_images/${DEPTH}.png

# Clean up
rm final_dominant.org
rm doors.txt
rm final_org_eval.txt


