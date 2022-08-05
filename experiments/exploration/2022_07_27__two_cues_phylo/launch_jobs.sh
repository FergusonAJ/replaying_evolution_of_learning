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

echo "Launching jobs for experiment: ${EXP_NAME}"

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
cp ${MABE_DIR}/build/MABE ${SCRATCH_FILE_DIR}
cp ${LAUNCH_DIR}/shared_files/* ${SCRATCH_FILE_DIR}

echo "Sending slurm files to dir: ${SCRATCH_SLURM_DIR}"
echo " "

# Pass the job script to sbatch, filling in some configuration variables
# Note: all variables in the job script will need the $ escaped!

sbatch <<EOF
#!/bin/bash --login
#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1g
#SBATCH --job-name ${EXP_NAME}
#SBATCH --array=1-100
#SBATCH --output=${SCRATCH_SLURM_DIR}/slurm-%A_%a.out
#SBATCH --qos=scavenger
#SBATCH --no-requeue

# Load the necessary modules
module purge
module load GCC/11.2.0
module load OpenMPI/4.1.1
module load R/4.1.2

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
SEED_BASE=1200000
SEED=\$((\${SEED_BASE} + \${SLURM_ARRAY_TASK_ID}))
echo "Random seed: \${SEED}: Replicate ID: \${SLURM_ARRAY_TASK_ID}"

# Grab all the needed directories
MABE_DIR=\${REPO_ROOT_DIR}/MABE2
MABE_EXTRAS_DIR=\${REPO_ROOT_DIR}/MABE2_extras
SCRATCH_EXP_DIR=\${SCRATCH_ROOT_DIR}/\${EXP_NAME}
SCRATCH_FILE_DIR=\${SCRATCH_EXP_DIR}/shared_files
SCRATCH_JOB_DIR=\${SCRATCH_EXP_DIR}/reps/\${SLURM_ARRAY_TASK_ID}

# Create replicate-specific directories
mkdir -p \${SCRATCH_JOB_DIR}
mkdir -p \${SCRATCH_JOB_DIR}/phylo
cd \${SCRATCH_JOB_DIR}

# Run!
#time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/evolution.mabe -s random_seed=\${SEED}
#Rscript ./final_org_check.R
#Rscript ./summarize_data.R

## Analyze final dominant org
#Rscript \${SCRATCH_FILE_DIR}/phylo_analysis.R
#DOMINANT_GENOME=\$(cat final_dominant_char.org)
#python3 \${SCRATCH_FILE_DIR}/genome_conversion.py -c \${DOMINANT_GENOME} final_dominant.org inst_set_output.txt 
#time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/analysis.mabe -s random_seed=\${SEED}
#mv single_org_fitness.csv final_dominant_org_fitness.csv
#
## Analyze orgs along the dominant lineage
#LINEAGE_FILE_LENGTH=\$(cat dominant_lineage.csv | wc -l)
#LINEAGE_LENGTH=\$((\${LINEAGE_FILE_LENGTH} - 2)) # -1 for header, -1 for starting at 0
#mkdir -p dominant_lineage_fitness
#for ((LINEAGE_IDX=0; LINEAGE_IDX<=\${LINEAGE_LENGTH}; LINEAGE_IDX++))
#do
#    SEED=\$((SEED + 1))
#    TMP_GENOME=\$(Rscript \${SCRATCH_FILE_DIR}/extract_from_lineage.R \${LINEAGE_IDX}) 
#    echo "Genome index \${LINEAGE_IDX}: \${TMP_GENOME}"
#    python3 \${SCRATCH_FILE_DIR}/genome_conversion.py -c \${TMP_GENOME} tmp.org inst_set_output.txt 
#    time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/analysis.mabe -s random_seed=\${SEED} -s avida_org.initial_genome_filename=\"tmp.org\" 
#    mv single_org_fitness.csv dominant_lineage_fitness/depth_\${LINEAGE_IDX}.csv
#done
Rscript \${SCRATCH_FILE_DIR}/summarize_lineage.R \${SLURM_ARRAY_TASK_ID}

scontrol show job \$SLURM_JOB_ID
EOF
