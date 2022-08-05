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

REPLAY_SEED=7
#REPLAY_DEPTH=16  # Done
#REPLAY_DEPTH=33  # Done
#REPLAY_DEPTH=49  # Done
#REPLAY_DEPTH=66  # Done 
#REPLAY_DEPTH=82  # Done 
#REPLAY_DEPTH=99  # Done 
#REPLAY_DEPTH=116 # Done
#REPLAY_DEPTH=133 # Done
#REPLAY_DEPTH=149 # Done
#REPLAY_DEPTH=166 # Done 
REPLAY_DEPTH=182 # Done
#REPLAY_DEPTH=199 # Done (100% learning)
#REPLAY_DEPTH=233 
#REPLAY_DEPTH=266 # Done
#REPLAY_DEPTH=299
#REPLAY_DEPTH=333 # Done
#REPLAY_DEPTH=366 
#REPLAY_DEPTH=399 # Done
MAX_UPDATES=250000
TIME_HOURS=23
TIME_MINUTES=59

echo "Launching replay jobs for experiment: ${EXP_NAME}"
echo "    Seed: ${REPLAY_SEED}; Depth: ${REPLAY_DEPTH}"

#### Grab references to the various directories used in setup
LAUNCH_DIR=`pwd`
MABE_DIR=${REPO_ROOT_DIR}/MABE2
MABE_EXTRAS_DIR=${REPO_ROOT_DIR}/MABE2_extras
SCRATCH_EXP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}
SCRATCH_FILE_DIR=${SCRATCH_EXP_DIR}/shared_files
SCRATCH_SLURM_DIR=${SCRATCH_EXP_DIR}/slurm

# Setup the directory structure
echo "Creating directory structure in: ${SCRATCH_EXP_DIR}"
mkdir -p ${SCRATCH_FILE_DIR}
mkdir -p ${SCRATCH_SLURM_DIR}
mkdir -p ${SCRATCH_EXP_DIR}/reps

# Copy all files that are shared across replicates
#cp ${MABE_DIR}/build/MABE ${SCRATCH_FILE_DIR}
#cp ${LAUNCH_DIR}/shared_files/* ${SCRATCH_FILE_DIR}

echo "Sending slurm files to dir: ${SCRATCH_SLURM_DIR}"
echo " "

# Pass the job script to sbatch, filling in some configuration variables
# Note: all variables in the job script will need the $ escaped!

sbatch <<EOF
#!/bin/bash --login
#SBATCH --time=${TIME_HOURS}:${TIME_MINUTES}:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2g
#SBATCH --job-name ${EXP_NAME}
#SBATCH --array=1-100
#SBATCH --output=${SCRATCH_SLURM_DIR}/slurm_replay_${REPLAY_SEED}_${REPLAY_DEPTH}-%A_%a.out

# Load the necessary modules
module purge
module load GCC/11.2.0
module load OpenMPI/4.1.1
module load R/4.1.2

# Fill in variables via launch script
REPLAY_SEED=${REPLAY_SEED}
REPLAY_DEPTH=${REPLAY_DEPTH}
MAX_UPDATES=${MAX_UPDATES}

#### Grab global variables, experiment name, etc.
# Do not touch this block unless you know what you're doing!
# Experiment name -> name of current directory
EXP_NAME=\$(pwd | grep -oP "/\K[^/]+$")
# Experiment directory -> current directory
EXP_DIR=\$(pwd)
# Root directory -> The root level of the repo, should be directory just above 'experiments'
REPO_ROOT_DIR=\$(pwd | grep -oP ".+/(?=experiments/)")
source \${REPO_ROOT_DIR}/config_global.sh

# Calculate the seed
SEED_BASE=1310000
OLD_SEED=\$((\${SEED_BASE} + \${SLURM_ARRAY_TASK_ID}))
echo "Old random seed: \${OLD_SEED}: Replicate ID: \${SLURM_ARRAY_TASK_ID}"
SEED_OFFSET=\$((1000 * \${REPLAY_SEED}))
SEED_OFFSET=\$((\${SEED_OFFSET} + \${SLURM_ARRAY_TASK_ID}))
NEW_SEED=\$((\${OLD_SEED} + \${SEED_OFFSET}))
echo "New random seed: \${NEW_SEED}: Replicate ID: \${SLURM_ARRAY_TASK_ID}"

# Grab all the needed directories
MABE_DIR=\${REPO_ROOT_DIR}/MABE2
MABE_EXTRAS_DIR=\${REPO_ROOT_DIR}/MABE2_extras
SCRATCH_EXP_DIR=\${SCRATCH_ROOT_DIR}/\${EXP_NAME}
SCRATCH_FILE_DIR=\${SCRATCH_EXP_DIR}/shared_files
SCRATCH_BASE_JOB_DIR=\${SCRATCH_EXP_DIR}/reps/\${REPLAY_SEED}
SCRATCH_JOB_DIR=\${SCRATCH_BASE_JOB_DIR}/replays/\${REPLAY_DEPTH}/\${SLURM_ARRAY_TASK_ID}

# Grab genome and origin time from old lineage
cd \${SCRATCH_BASE_JOB_DIR}
START_GENOME=\$(Rscript \${SCRATCH_FILE_DIR}/extract_from_lineage.R \${REPLAY_DEPTH}) 
ORIGIN_TIME=\$(Rscript \${SCRATCH_FILE_DIR}/extract_from_lineage.R \${REPLAY_DEPTH} origin_time) 
REPLAY_UPDATES=\$(( \${MAX_UPDATES} - \${ORIGIN_TIME} ))

# Create replicate-specific directories
mkdir -p \${SCRATCH_JOB_DIR}
mkdir -p \${SCRATCH_JOB_DIR}/phylo
cd \${SCRATCH_JOB_DIR}

# Convert the genome into format MABE2 expects
python3 \${SCRATCH_FILE_DIR}/genome_conversion.py -c \${START_GENOME} base.org \${SCRATCH_BASE_JOB_DIR}/inst_set_output.txt 

# Run!
time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/evolution.mabe -s random_seed=\${NEW_SEED} -s avida_org.inst_set_input_filename=\"\${SCRATCH_FILE_DIR}/inst_set_input.txt\" -s avida_org.initial_genome_filename=\"base.org\" -s max_updates=\${REPLAY_UPDATES}

# Analyze final dominant org
Rscript \${SCRATCH_FILE_DIR}/phylo_analysis.R \${REPLAY_UPDATES}
DOMINANT_GENOME=\$(cat final_dominant_char.org)
python3 \${SCRATCH_FILE_DIR}/genome_conversion.py -c \${DOMINANT_GENOME} final_dominant.org inst_set_output.txt 
time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/analysis.mabe -s random_seed=\${NEW_SEED} -s avida_org.inst_set_input_filename=\"\${SCRATCH_FILE_DIR}/inst_set_input.txt\" 
mv single_org_fitness.csv final_dominant_org_fitness.csv

scontrol show job \$SLURM_JOB_ID
EOF
