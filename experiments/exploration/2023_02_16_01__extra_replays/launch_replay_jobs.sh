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

#### Grab references to the various directories used in setup
LAUNCH_DIR=`pwd`
SCRATCH_EXP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}
SCRATCH_FILE_DIR=${SCRATCH_EXP_DIR}/shared_files
SCRATCH_SLURM_DIR=${SCRATCH_EXP_DIR}/slurm
SCRATCH_SLURM_OUT_DIR=${SCRATCH_SLURM_DIR}/out
SCRATCH_SLURM_JOB_DIR=${SCRATCH_SLURM_DIR}/jobs

MAX_UPDATES=250000
REPLAY_SEED=28
# 00 [X] 600
#    [X] 563
# 06 [X] 525
#    [X] 488
# 02 [X] 450
#    [X] 413
# 04 [X] 375
#    [X] 338
# 01 [X] 300
#    [X] 263
# 05 [X] 225
#    [X] 188
# 03 [X] 150
#    [X] 113
# 07 [X] 75 
#    [X] 38
# -1 [X] 0
# Batch 1:
#for REPLAY_DEPTH in 600 300 450 150 375
# Batch 2:
#for REPLAY_DEPTH in 225 525 75 
# Batch 3:
#for REPLAY_DEPTH in 563 488 413 338 263 188 113 38
# Batch 4 (switching to 50 reps per depth):
#for REPLAY_DEPTH in 412 411 410 409 408 407 406 405 404 403 402 401 400 399 398 397 396 395 394 393 392 391 390 389 388 387 386 385 384 383 382 381 380 379 378 377 376
# Batch 5 (rerunning key steps with more replicates):
for REPLAY_DEPTH in 394 393 392 391 
do
    echo "Launching replay jobs for experiment: ${EXP_NAME}"
    echo "    Seed: ${REPLAY_SEED}; Depth: ${REPLAY_DEPTH}"

    echo "Generating slurm job scripts in dir: ${SCRATCH_SLURM_JOB_DIR}"
    echo "Sending slurm output to dir: ${SCRATCH_SLURM_OUT_DIR}"

    # Create output sbatch file, and find/replace key info
    sed -e "s/(<EXP_NAME>)/${EXP_NAME}/g" replay_job_template.sb > out.sb
    ESCAPED_SCRATCH_SLURM_OUT_DIR=$(echo "${SCRATCH_SLURM_OUT_DIR}" | sed -e "s/\//\\\\\//g")
    sed -i -e "s/(<SCRATCH_SLURM_OUT_DIR>)/${ESCAPED_SCRATCH_SLURM_OUT_DIR}/g" out.sb
    ESCAPED_SCRATCH_EXP_DIR=$(echo "${SCRATCH_EXP_DIR}" | sed -e "s/\//\\\\\//g")
    sed -i -e "s/(<SCRATCH_EXP_DIR>)/${ESCAPED_SCRATCH_EXP_DIR}/g" out.sb
    ESCAPED_SCRATCH_FILE_DIR=$(echo "${SCRATCH_FILE_DIR}" | sed -e "s/\//\\\\\//g")
    sed -i -e "s/(<SCRATCH_FILE_DIR>)/${ESCAPED_SCRATCH_FILE_DIR}/g" out.sb
    sed -i -e "s/(<REPLAY_SEED>)/${REPLAY_SEED}/g" out.sb
    sed -i -e "s/(<REPLAY_DEPTH>)/${REPLAY_DEPTH}/g" out.sb
    sed -i -e "s/(<MAX_UPDATES>)/${MAX_UPDATES}/g" out.sb

    # Move output sbatch file to final destination, and add to roll_q queue
    TIMESTAMP=`date +%m_%d_%y__%H_%M_%S`
    SLURM_FILENAME=${SCRATCH_SLURM_JOB_DIR}/replay_${REPLAY_SEED}_${REPLAY_DEPTH}__${EXP_NAME}__${TIMESTAMP}.sb
    mv out.sb ${SLURM_FILENAME} 
    echo "${SLURM_FILENAME}" >> ${ROLL_Q_DIR}/roll_q_job_array.txt
    echo "Finished creating jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
    echo ""

done # End for loop
echo "Finished creating all jobs."
