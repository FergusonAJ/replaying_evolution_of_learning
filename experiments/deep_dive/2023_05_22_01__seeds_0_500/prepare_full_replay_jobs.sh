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
#REPLAY_SEEDS="93 221 299 327 422 458 476 477"
#declare -a DEPTH_MAP
#DEPTH_MAP[93]="1010 960 910 860 810 760 710 660 610"
#DEPTH_MAP[221]="1333 1283 1233 1183 1133 1083 1033 983 933"
#DEPTH_MAP[299]="1443 1393 1343 1293 1243 1193 1143 1093 1043 993 943 893 843"
#DEPTH_MAP[327]="1247 1197 1147 1097 1047 997 947 897 847"
#DEPTH_MAP[422]="2990 2940 2890 2840 2790 2740 2690 2640 2590 2540 2490 2440 2390 2340 2290 2240 2190 2140 2090 2040 1990 1940 1890 1840 1790 1740 1690 1640 1590 1540 1490 1440 1390 1340 1290 1240 1190 1140 1090 1040 990 940 890"
#DEPTH_MAP[458]="1078 1028 978 928 878 828 778 728 678 628 578"
#DEPTH_MAP[476]="2929 2879 2829 2779 2729 2679 2629 2579 2529 2479 2429 2379 2329 2279 2229 2179 2129 2079 2029 1979 1929 1879 1829 1779 1729 1679 1629 1579 1529 1479 1429 1379 1329 1279 1229 1179 1129 1079"
#DEPTH_MAP[477]="1188 1138 1088 1038 988 938 888 838 788 738 688 638 588"
REPLAY_SEEDS="422 458"
declare -a DEPTH_MAP
DEPTH_MAP[422]="840 790 740 690 640 590"
DEPTH_MAP[458]="528 478 428 378 328 278"

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
