#!/bin/bash

# This file creates and fills the experiment's directory on scratch. 
# It then calls sbatch itself.
# This is done so the job name and output directory can use variables
# That part is adapted from here: https://stackoverflow.com/a/70740950

# Allow user to launch these mock jobs with -m
IS_MOCK=0
while getopts ":ml" opt; do
  case $opt in
    m)
     IS_MOCK=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

#### Grab global variables, experiment name, etc.
# Do not touch this block unless you know what you're doing!
# Experiment name -> name of current directory
EXP_NAME=$(pwd | grep -oP "/\K[^/]+$")
# Experiment directory -> current directory
EXP_DIR=$(pwd)
# Root directory -> The root level of the repo, should be directory just above 'experiments'
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

# Switch to mock scratch, if requested
if [ ${IS_MOCK} -gt 0 ]
then
  SCRATCH_ROOT_DIR=${EXP_DIR}/mock_scratch
  mkdir -p ${SCRATCH_ROOT_DIR}
  echo "Preparing *mock* jobs"
fi

#### Grab references to the various directories used in setup
LAUNCH_DIR=`pwd`
SCRATCH_EXP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}
SCRATCH_FILE_DIR=${SCRATCH_EXP_DIR}/shared_files
SCRATCH_SLURM_DIR=${SCRATCH_EXP_DIR}/slurm
SCRATCH_SLURM_OUT_DIR=${SCRATCH_SLURM_DIR}/out
SCRATCH_SLURM_JOB_DIR=${SCRATCH_SLURM_DIR}/jobs

mkdir -p ${SCRATCH_FILE_DIR}
mkdir -p ${SCRATCH_SLURM_DIR}
mkdir -p ${SCRATCH_SLURM_OUT_DIR}
mkdir -p ${SCRATCH_SLURM_JOB_DIR}
mkdir -p ${SCRATCH_EXP_DIR}/reps

MAX_UPDATES=250000

## Run replays for all single mutations at the largest potentiating step 
REPLAY_SEEDS="10 20"
declare -a GENOME_MAP
GENOME_MAP[10]="FkHOKHSaONuadPpGhHPIyaMAgPypmmpdLdHBFdRdnoLzMBRNbJPPpDPeqHNJCBAfDFlqJgqgLnPNpqQRwiuucFPcKlxxoHuuM FkHOKHSaONuadPpGhHPIyaMAgPypmmpdLdHBFdRSnoLzMBRNbJPPpDPeqHNJCBAfDFlqJgqgLnPNpqQRwiuucgPcKlxxoHuuM "
GENOME_MAP[20]="HopLIHPISGBbhKGsRLHNJHqjGKqkjOqRrlmmncyrGPsnhAjugFhfsyDdvkMsAvoipogKGoEbPOfBycNHawcFRuFCDPbOKxQtLjsqywzQBuCpdFkdlCDhuchNJCjS HopCIHPISGBbhKGsRLHNJHqjGKqkjOqRrlmmncyrGPsnhAjugFhfsyDdvkMsAvoipogKGoEbPOfBycNHawcFRuFCDPbOKxQtLjsqywzQBuCpdFkdlfDhuchNJCjS "
declare -a DEPTH_MAP
DEPTH_MAP[10]="683"
DEPTH_MAP[20]="3403"

for REPLAY_SEED in ${REPLAY_SEEDS}
do
    echo "Starting seed: ${REPLAY_SEED}"
    GENOME_IDX=0
    REPLAY_DEPTH=${DEPTH_MAP[REPLAY_SEED]}
    for START_GENOME in ${GENOME_MAP[REPLAY_SEED]}
    do
        echo "Launching full replay jobs for experiment: ${EXP_NAME}"
        echo "    Seed: ${REPLAY_SEED}; Depth: ${REPLAY_DEPTH}"
        echo "    Genome index: ${GENOME_IDX}; Genome: ${START_GENOME}"

        echo "Generating slurm job scripts in dir: ${SCRATCH_SLURM_JOB_DIR}"
        echo "Sending slurm output to dir: ${SCRATCH_SLURM_OUT_DIR}"

        # Create output sbatch file, and find/replace key info
        sed -e "s/(<EXP_NAME>)/${EXP_NAME}/g" job_template_mutation_split.sb > out.sb
        ESCAPED_SCRATCH_SLURM_OUT_DIR=$(echo "${SCRATCH_SLURM_OUT_DIR}" | sed -e "s/\//\\\\\//g")
        sed -i -e "s/(<SCRATCH_SLURM_OUT_DIR>)/${ESCAPED_SCRATCH_SLURM_OUT_DIR}/g" out.sb
        ESCAPED_SCRATCH_EXP_DIR=$(echo "${SCRATCH_EXP_DIR}" | sed -e "s/\//\\\\\//g")
        sed -i -e "s/(<SCRATCH_EXP_DIR>)/${ESCAPED_SCRATCH_EXP_DIR}/g" out.sb
        ESCAPED_SCRATCH_FILE_DIR=$(echo "${SCRATCH_FILE_DIR}" | sed -e "s/\//\\\\\//g")
        sed -i -e "s/(<SCRATCH_FILE_DIR>)/${ESCAPED_SCRATCH_FILE_DIR}/g" out.sb
        sed -i -e "s/(<REPLAY_SEED>)/${REPLAY_SEED}/g" out.sb
        sed -i -e "s/(<REPLAY_DEPTH>)/${REPLAY_DEPTH}/g" out.sb
        sed -i -e "s/(<MAX_UPDATES>)/${MAX_UPDATES}/g" out.sb
        sed -i -e "s/(<START_GENOME>)/${START_GENOME}/g" out.sb
        sed -i -e "s/(<GENOME_IDX>)/${GENOME_IDX}/g" out.sb

        # Move output sbatch file to final destination, and add to roll_q queue
        TIMESTAMP=`date +%m_%d_%y__%H_%M_%S`
        SLURM_FILENAME=${SCRATCH_SLURM_JOB_DIR}/mut_split_${REPLAY_SEED}_${GENOME_IDX}__${EXP_NAME}__${TIMESTAMP}.sb
        mv out.sb ${SLURM_FILENAME} 
        if [ ${IS_MOCK} -gt 0 ]
        then
          echo "Finished creating *mock* jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
        else
          echo "${SLURM_FILENAME}" >> ${ROLL_Q_DIR}/roll_q_job_array.txt
          echo "Finished creating jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
        fi
        echo ""
        GENOME_IDX=$(( GENOME_IDX + 1 ))
    done # End START_GENOME for loop
done # End REPLAY_SEED for loop

echo "Finished creating all jobs."
if [ ${IS_MOCK} -eq 0 ]
then
  echo "Run roll_q to queue jobs. roll_q directory:"
  echo "${ROLL_Q_DIR}"
fi
