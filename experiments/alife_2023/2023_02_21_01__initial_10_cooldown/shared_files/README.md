## Directory

### MABE configuration scripts
- `./base_3c1s_config.mabe` - The main configuration script that defines the modules shared across phases. Copied from `global_shared_files` at the root of this repo so changes there will not affect the ALife submission.
- `./config_diff.mabe` - Any differences between the default config above. 
- `./evolution.mabe` - The modules and logic needed for evolution in the initial 200 replicates. 
- `./analysis.mabe` - Analysis logic for a single organsim. 
- `./evolution_replay.mabe` - A variant of `./evolution.mabe` used for replay experiments. 
- `./mutant_analysis.mabe` - Analysis logic for one- and two-step mutations. 

### Scripts
- `./plot_doors.py` - Visualization script that creates the images seen in `../images`

### Required files
- `./ancestor.org` - The initial ancestral genotype. Does nothing but reproduce. 
- `./inst_set_input.txt` - The instruction set used in this work. 
