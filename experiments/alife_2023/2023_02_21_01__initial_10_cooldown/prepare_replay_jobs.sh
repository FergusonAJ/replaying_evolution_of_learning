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
#REPLAY_SEED=86
# Seed 86 batch 1:
#for REPLAY_DEPTH in 1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50
# Seed 86 batch 2:
#REPLAY_DEPTHS="451 452 453 454 455 456 457 458 459 460 461 462 463 464 465 466 467 468 469 470 471 472 473 474 475 476 477 478 479 480 481 482 483 484 485 486 487 488 489 490 491 492 493 494 495 496 497 498 499 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 419 420 421 422 423 424 425 426 427 428 429 430 431 432 433 434 435 436 437 438 439 440 441 442 443 444 445 446 447 448 449"
#REPLAY_SEED=4
# Seed 4 batch 1:
#for REPLAY_DEPTH in 1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50
# Seed 4 batch 2:
#REPLAY_DEPTHS="101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99"
#REPLAY_SEED=15
#for REPLAY_DEPTH in 1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50
#REPLAY_DEPTHS="251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299"
#REPLAY_SEED=6
#for REPLAY_DEPTH in 1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50
#REPLAY_DEPTHS="501 502 503 504 505 506 507 508 509 510 511 512 513 514 515 516 517 518 519 520 521 522 523 524 525 526 527 528 529 530 531 532 533 534 535 536 537 538 539 540 541 542 543 544 545 546 547 548 549 550"
#REPLAY_SEED=29
#for REPLAY_DEPTH in 1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50
#REPLAY_SEED=30
#REPLAY_DEPTHS="2400 2300 2200 2100 2000 1900 1800 1700 1600 1500 1400 1300 1200 1100"
#REPLAY_SEED=94
#REPLAY_DEPTHS="1450 1400 1350 1300 1250 1200 1150 1100 1050"
REPLAY_SEED=100
REPLAY_DEPTHS="3300 3200 3100 3000 2900 2800 2700 2600 2500 2400 2300 2200 2100 2000 1900 1800 1700 1600 1500 1400 1300 1200 1100"
#REPLAY_DEPTHS="1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50"
### End of first 8 seeds
#REPLAY_SEED=101
#REPLAY_SEED=112
#REPLAY_SEED=142
#REPLAY_SEED=145
#REPLAY_SEED=147
#REPLAY_SEED=150
#REPLAY_SEED=154
#REPLAY_SEED=179
#REPLAY_DEPTHS="1000 950 900 850 800 750 700 650 600 550 500 450 400 350 300 250 200 150 100 50"
for REPLAY_DEPTH in ${REPLAY_DEPTHS}
do
    echo "Launching replay jobs for experiment: ${EXP_NAME}"
    echo "    Seed: ${REPLAY_SEED}; Depth: ${REPLAY_DEPTH}"

    echo "Generating slurm job scripts in dir: ${SCRATCH_SLURM_JOB_DIR}"
    echo "Sending slurm output to dir: ${SCRATCH_SLURM_OUT_DIR}"

    # Create output sbatch file, and find/replace key info
    sed -e "s/(<EXP_NAME>)/${EXP_NAME}/g" job_template_replay.sb > out.sb
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
    if [ ${IS_MOCK} -gt 0 ]
    then
      echo "Finished creating *mock* jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
    else
      echo "${SLURM_FILENAME}" >> ${ROLL_Q_DIR}/roll_q_job_array.txt
      echo "Finished creating jobs (seed: ${REPLAY_SEED}; depth: ${REPLAY_DEPTH})"
    fi
    echo ""
done # End for loop

echo "Finished creating all jobs."
if [ ${IS_MOCK} -eq 0 ]
then
  echo "Run roll_q to queue jobs. roll_q directory:"
  echo "${ROLL_Q_DIR}"
fi
