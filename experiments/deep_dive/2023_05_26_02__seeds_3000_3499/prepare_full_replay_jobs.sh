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
#REPLAY_SEEDS="128 156 184 223 278 365 406 426 485"
#DEPTH_MAP[128]="3315 3265 3215 3165 3115"
#DEPTH_MAP[156]="1780 1730 1680 1630 1580"
#DEPTH_MAP[184]="1761 1711 1661 1611 1561"
#DEPTH_MAP[223]="1524 1474 1424 1374 1324"
#DEPTH_MAP[278]="1402 1352 1302 1252 1202"
#DEPTH_MAP[365]="1430 1380 1330 1280 1230"
#DEPTH_MAP[406]="905 855 805 755 705"
#DEPTH_MAP[426]="1694 1644 1594 1544 1494"
#DEPTH_MAP[485]="1365 1315 1265 1215 1165"

#REPLAY_SEEDS="128 156 184 223 365 406 426"
#declare -a DEPTH_MAP
#DEPTH_MAP[128]="3065 3015 2965 2915 2865 2815"
#DEPTH_MAP[156]="1530 1480 1430 1380 1330 1280"
#DEPTH_MAP[184]="1511 1461 1411 1361 1311 1261"
#DEPTH_MAP[223]="1274 1224 1174 1124 1074 1024"
#DEPTH_MAP[365]="1180 1130 1080 1030 980 930"
#DEPTH_MAP[406]="655 605 555 505 455 405"
#DEPTH_MAP[426]="1444 1394 1344 1294 1244 1194"

#REPLAY_SEEDS="156 184 223 426"
#declare -a DEPTH_MAP
#DEPTH_MAP[156]="1230 1180 1130 1080 1030 980"
#DEPTH_MAP[184]="1211 1161 1111 1061 1011 961"
#DEPTH_MAP[223]="974 924 874 824 774 724"
#DEPTH_MAP[426]="1144 1094 1044 994 944 894"

#REPLAY_SEEDS="184 223 426"
#declare -a DEPTH_MAP
#DEPTH_MAP[184]="911 861 811 761 711 661"
#DEPTH_MAP[223]="674 624 574 524 474 424"
#DEPTH_MAP[426]="844 794 744 694 644 594"

REPLAY_SEEDS="223 426"
declare -a DEPTH_MAP
DEPTH_MAP[223]="374 324 274 224 174 124"
DEPTH_MAP[426]="544 494 444 394 344 294"

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
