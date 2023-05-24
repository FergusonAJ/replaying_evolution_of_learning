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
REPLAY_SEED=50

# Batch 1:
#for REPLAY_DEPTH in 475 450 425 400 375 350 325 300 275 250 225 200 175 150 125 100 75 50 25

# Batch 2:
#for REPLAY_DEPTH in 299 298 297 296 295 294 293 292 291 290 289 288 287 286 285 284 283 282 281 280 279 278 277 276 274 273 272 271 270 269 268 267 266 265 264 263 262 261 260 259 258 257 256 255 254 253 252 251
for REPLAY_DEPTH in 264 263 262 261 260 259 258 257 256 255 254 253 252 251
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
