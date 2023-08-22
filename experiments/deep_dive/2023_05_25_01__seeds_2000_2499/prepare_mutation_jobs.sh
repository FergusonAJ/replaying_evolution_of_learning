#!/bin/bash

# This file creates and fills the experiment's directory on scratch. 
# It then creates the job's sbatch file and adds the job to roll_q (unless it's a mock job)

# Allow user to prepare mock jobs with -m
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
MABE_DIR=${REPO_ROOT_DIR}/MABE2
MABE_EXTRAS_DIR=${REPO_ROOT_DIR}/MABE2_extras
GLOBAL_FILE_DIR=${REPO_ROOT_DIR}/global_shared_files
SCRATCH_EXP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}
SCRATCH_FILE_DIR=${SCRATCH_EXP_DIR}/shared_files
SCRATCH_SLURM_DIR=${SCRATCH_EXP_DIR}/slurm
SCRATCH_SLURM_OUT_DIR=${SCRATCH_SLURM_DIR}/out
SCRATCH_SLURM_JOB_DIR=${SCRATCH_SLURM_DIR}/jobs

# Create needed folders
mkdir -p ${SCRATCH_FILE_DIR}
mkdir -p ${SCRATCH_SLURM_DIR}
mkdir -p ${SCRATCH_SLURM_OUT_DIR}
mkdir -p ${SCRATCH_SLURM_JOB_DIR}
mkdir -p ${SCRATCH_EXP_DIR}/reps

# Copy all files that are shared across replicates
cp ${MABE_DIR}/build/MABE ${SCRATCH_FILE_DIR}
cp ${LAUNCH_DIR}/shared_files/* ${SCRATCH_FILE_DIR}
cp ${GLOBAL_FILE_DIR}/* ${SCRATCH_FILE_DIR}

FOCAL_SEEDS="95 186 208 210 409"
declare -a DEPTH_MAP
DEPTH_MAP[95]="1290"
DEPTH_MAP[186]="675"
DEPTH_MAP[208]="160"
DEPTH_MAP[210]="2144"
DEPTH_MAP[409]="480"

for FOCAL_SEED in ${FOCAL_SEEDS}
do
  FOCAL_DEPTH=${DEPTH_MAP[FOCAL_SEED]}
  echo "Preparing mutation jobs for experiment: ${EXP_NAME}"
  echo "    Seed: ${FOCAL_SEED}; Depth: ${FOCAL_DEPTH}"
  
  echo "Generating slurm job scripts in dir: ${SCRATCH_SLURM_JOB_DIR}"
  echo "Sending slurm output to dir: ${SCRATCH_SLURM_OUT_DIR}"
  
  # Create output sbatch file, and find/replace key info
  sed -e "s/(<EXP_NAME>)/${EXP_NAME}/g" job_template_mutation.sb > out.sb
  ESCAPED_SCRATCH_SLURM_OUT_DIR=$(echo "${SCRATCH_SLURM_OUT_DIR}" | sed -e "s/\//\\\\\//g")
  sed -i -e "s/(<SCRATCH_SLURM_OUT_DIR>)/${ESCAPED_SCRATCH_SLURM_OUT_DIR}/g" out.sb
  ESCAPED_SCRATCH_EXP_DIR=$(echo "${SCRATCH_EXP_DIR}" | sed -e "s/\//\\\\\//g")
  sed -i -e "s/(<SCRATCH_EXP_DIR>)/${ESCAPED_SCRATCH_EXP_DIR}/g" out.sb
  ESCAPED_SCRATCH_FILE_DIR=$(echo "${SCRATCH_FILE_DIR}" | sed -e "s/\//\\\\\//g")
  sed -i -e "s/(<SCRATCH_FILE_DIR>)/${ESCAPED_SCRATCH_FILE_DIR}/g" out.sb
  sed -i -e "s/(<FOCAL_SEED>)/${FOCAL_SEED}/g" out.sb
  sed -i -e "s/(<FOCAL_DEPTH>)/${FOCAL_DEPTH}/g" out.sb
  
  # Move output sbatch file to final destination, and add to roll_q queue if needed
  TIMESTAMP=`date +%m_%d_%y__%H_%M_%S`
  SLURM_FILENAME=${SCRATCH_SLURM_JOB_DIR}/mut_${FOCAL_SEED}_${FOCAL_DEPTH}__${EXP_NAME}__${TIMESTAMP}.sb
  mv out.sb ${SLURM_FILENAME} 
  if [ ${IS_MOCK} -gt 0 ]
  then
    chmod u+x ${SLURM_FILENAME}
    echo "Finished creating *mock* jobs (seed: ${FOCAL_SEED}; depth: ${FOCAL_DEPTH})"
  else
    echo "${SLURM_FILENAME}" >> ${ROLL_Q_DIR}/roll_q_job_array.txt
    echo "Finished creating jobs (seed: ${FOCAL_SEED}; depth: ${FOCAL_DEPTH})"
  fi
  
  echo ""
done # End for loop
  
echo "Finished creating all jobs."
if [ ${IS_MOCK} -eq 0 ]
then
  echo "Run roll_q to queue jobs. roll_q directory:"
  echo "${ROLL_Q_DIR}"
fi
