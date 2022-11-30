#!/bin/bash

# This file creates and fills the experiment's directory on scratch. 
# It then calls sbatch itself.
# This is done so the job name and output directory can use variables
# That part is adapted from here: https://stackoverflow.com/a/70740950

#### Grab global variables, experiment name, etc.
# Do not touch this block unless you know what you're doing!
# Experiment name -> name of current directory
EXP_NAME=$(pwd | grep -oP "/\K[^/]+$")
# Experiment directory -> current directory
EXP_DIR=$(pwd)
# Root directory -> The root level of the repo, should be directory just above 'experiments'
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

echo " "
echo "Creating jobs for experiment: ${EXP_NAME}"

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
BASE_ROLL_Q_DIR=${REPO_ROOT_DIR}/roll_q

# Setup the directory structure
echo " "
echo "Creating directory structure in: ${SCRATCH_EXP_DIR}"
mkdir -p ${SCRATCH_FILE_DIR}
mkdir -p ${SCRATCH_SLURM_DIR}
mkdir -p ${SCRATCH_SLURM_OUT_DIR}
mkdir -p ${SCRATCH_SLURM_JOB_DIR}
mkdir -p ${SCRATCH_EXP_DIR}/reps

# Initialize roll_q if needed
if [ ! -d ${ROLL_Q_DIR} ]
then
    echo "roll_q not found on scratch! Copying and initializing..."
    cp ${BASE_ROLL_Q_DIR} ${ROLL_Q_DIR} -r
    echo "0" > ${ROLL_Q_DIR}/roll_q_idx.txt
    rm ${ROLL_Q_DIR}/roll_q_job_array.txt
    touch ${ROLL_Q_DIR}/roll_q_job_array.txt
    echo "roll_q initialized!"
fi

# Copy all files that are shared across replicates
cp ${MABE_DIR}/build/MABE ${SCRATCH_FILE_DIR}
cp ${LAUNCH_DIR}/shared_files/* ${SCRATCH_FILE_DIR}
cp ${GLOBAL_FILE_DIR}/* ${SCRATCH_FILE_DIR}

# Tell user where files are going
echo " "
echo "Sending generated slurm job file to dir: ${SCRATCH_SLURM_JOB_DIR}"
echo "Sending slurm output files to dir: ${SCRATCH_SLURM_OUT_DIR}"
echo " "

# Create output sbatch file, and find/replace key info
sed -e "s/(<EXP_NAME>)/${EXP_NAME}/g" job_template.sb > out.sb
ESCAPED_SCRATCH_SLURM_OUT_DIR=$(echo "${SCRATCH_SLURM_OUT_DIR}" | sed -e "s/\//\\\\\//g")
sed -i -e "s/(<SCRATCH_SLURM_OUT_DIR>)/${ESCAPED_SCRATCH_SLURM_OUT_DIR}/g" out.sb
ESCAPED_SCRATCH_EXP_DIR=$(echo "${SCRATCH_EXP_DIR}" | sed -e "s/\//\\\\\//g")
sed -i -e "s/(<SCRATCH_EXP_DIR>)/${ESCAPED_SCRATCH_EXP_DIR}/g" out.sb
ESCAPED_SCRATCH_FILE_DIR=$(echo "${SCRATCH_FILE_DIR}" | sed -e "s/\//\\\\\//g")
sed -i -e "s/(<SCRATCH_FILE_DIR>)/${ESCAPED_SCRATCH_FILE_DIR}/g" out.sb

# Move output sbatch file to final destination, and add to roll_q queue
TIMESTAMP=`date +%m_%d_%y__%H_%M_%S`
SLURM_FILENAME=${SCRATCH_SLURM_JOB_DIR}/${EXP_NAME}__${TIMESTAMP}.sb
mv out.sb ${SLURM_FILENAME} 
echo "${SLURM_FILENAME}" >> ${ROLL_Q_DIR}/roll_q_job_array.txt
echo ""
echo "Finished creating jobs."
echo ""
