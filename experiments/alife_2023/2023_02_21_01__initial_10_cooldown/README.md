This is the main directory for the ALife 2023 experiment. 
All the files needed to generate the initial replicates, analyze them, and then run replays and mutation data are all here. 

## Directory
- `./analysis/` - The R scripts used to analyze the data _locally_, after it has been pulled from the cluster.
- `./data/` - All data for the replicates, including their replays and mutants.
- `./images/` - Images showing how all 200 of the initial replicates navigated the environment.
- `./local_analysis/` - Used to run local tests, such as calculating execution traces on specific organisms. 
- `./shared_files/` - Contains all configuration files and scripts needed for running the experiments in a separate folder (like the scratch space of a computing cluser)
  - Note this gets copied to that location _after_ `/global_shared_files/`, so any duplicate files will use this version.
- `./job_template_evolution.sb` - The actual pseudo-bash script used for running a single evolution replicate (from the initial 200). 
- `./job_template_mutation.sb` - The actual pseudo-bash script used for running a one- or two-step mutations.
- `./job_template_replay.sb` - The actual pseudo-bash script used for running replay replicates for a given depth in the dominant lineage. 
- `./prepare_jobs.sb` - Used to populate `./job_template_evolution.sb` with appropriate information and sends a copy of that file to the scratch space to be launched. 
- `./prepare_mutation_jobs.sb` - Used to populate `./job_template_mutation.sb` with appropriate information and sends a copy of that file to the scratch space to be launched. 
- `./prepare_replay_jobs.sb` - Used to populate `./job_template_replay.sb` with appropriate information and sends a copy of that file to the scratch space to be launched. 
