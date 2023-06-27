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

MAX_UPDATES=250000

#declare -a DEPTH_MAP
##REPLAY_SEEDS="8 10 20 57 141 185 305 359"
#REPLAY_SEEDS="8 305"
#declare -a DEPTH_MAP
##DEPTH_MAP[8]="1916 1866 1816 1766 1716"
##DEPTH_MAP[8]="1666 1616 1566 1516 1466 1416 1366 1316 1266 1216"
#DEPTH_MAP[8]="1166 1116 1066 1016 966 916 866 816 866 816"
#DEPTH_MAP[10]="816 766 716 666 616"
#DEPTH_MAP[20]="3413 3363 3313 3263 3213"
##DEPTH_MAP[57]="3319 3269 3219 3169 3119"
#DEPTH_MAP[57]="3069 3019 2969 2919 2869 2819 2769 2719 2669 2619"
#DEPTH_MAP[141]="474 424 374 324 274"
#DEPTH_MAP[185]="633 583 533 483 433"
##DEPTH_MAP[305]="1774 1724 1674 1624 1574"
##DEPTH_MAP[305]="1524 1474 1424 1374 1324 1274 1224 1174 1124"
#DEPTH_MAP[305]="1074 1024 974 924 874 824 774 724 674 624 574"
#DEPTH_MAP[359]="1895 1845 1795 1745 1695"

#REPLAY_SEEDS="305"
#declare -a DEPTH_MAP
#DEPTH_MAP[305]="1174 1224 1274 1324 1374 1424 1474 1524"

#REPLAY_SEEDS="8 305"
#declare -a DEPTH_MAP
#DEPTH_MAP[8]="1166 1116 1066 1016 966 916"
#DEPTH_MAP[305]="1074 1024 974 924 874 824"

#REPLAY_SEEDS="8 305"
#declare -a DEPTH_MAP
#DEPTH_MAP[8]="866 816 766 716 666 616"
#DEPTH_MAP[305]="774 724 674 624 574 524"

#REPLAY_SEEDS="305"
#declare -a DEPTH_MAP
#DEPTH_MAP[305]="1174 1224 1274 1324 1374 1424 1474 1524"

REPLAY_SEEDS="305"
declare -a DEPTH_MAP
DEPTH_MAP[305]="474 424 374 324 274 224"


for REPLAY_SEED in ${REPLAY_SEEDS}
do
    echo "Starting seed: ${REPLAY_SEED}"
    for REPLAY_DEPTH in ${DEPTH_MAP[REPLAY_SEED]}
    do
        echo "Launching full replay jobs for experiment: ${EXP_NAME}"
        echo "    Seed: ${REPLAY_SEED}; Depth: ${REPLAY_DEPTH}"

        echo "Generating slurm job scripts in dir: ${SCRATCH_SLURM_JOB_DIR}"
        echo "Sending slurm output to dir: ${SCRATCH_SLURM_OUT_DIR}"

        # Create output sbatch file, and find/replace key info
        sed -e "s/(<EXP_NAME>)/${EXP_NAME}/g" job_template_full_replay.sb > out.sb
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
        SLURM_FILENAME=${SCRATCH_SLURM_JOB_DIR}/full_replay_${REPLAY_SEED}_${REPLAY_DEPTH}__${EXP_NAME}__${TIMESTAMP}.sb
        mv out.sb ${SLURM_FILENAME} 
        if [ ${IS_MOCK} -gt 0 ]
        then
          echo "Finished creating *mock* jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
        else
          echo "${SLURM_FILENAME}" >> ${ROLL_Q_DIR}/roll_q_job_array.txt
          echo "Finished creating jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
        fi
        echo ""
    done # End REPLAY_DEPTH for loop
done # End REPLAY_SEED for loop

echo "Finished creating all jobs."
if [ ${IS_MOCK} -eq 0 ]
then
  echo "Run roll_q to queue jobs. roll_q directory:"
  echo "${ROLL_Q_DIR}"
fi
