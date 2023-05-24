Here we group scripts by how they are used: 

## MABE configuration scripts
- `./base_3c1s_config.mabe` - Includes all the modules and variables used in both the evolution and analysis phases of 3c1s experiments (three cues, one set).

## Widely-used analyses and supporting files
- `./shared_funcs__three_cues_one_set.R` - Contains all logic for categorizing and summarizing data in 3c1s experiments.
- `./shared_funcs__two_cues.R` - Same as above but for the simpler two cues environment.
- `./constant_vars__three_cues_one_set.R` - Variables used across files (including shared funcs above). Things like category names, color maps, etc.
- `./shared_funcs__two_cues.R` - Contains all logic for categorizing and summarizing data in 3c1s experiments.

## Analyses and tools used within an experiment
- `./summarize_lineage__three_cues_one_set.R` - We have to analyze genotypes in a lineage one at a time. This script combines all those outputs back into one csv.
- `./shared_funcs__two_cues.R` - Same as above for the simpler two cues environment. 
- `./phylo_analysis.R` - Summarizes the raw phylogeny data from MABE. 
- `./extract_from_lineage.R` - Allows command line users to pull any piece of data from a given depth in the phylogeny. 
- `./genome_conversion.py` - Converts genotypes between character strings (e.g., 'aaabc') to one-instruction-per-line files with full instruction names. Comes from MABE2_extras.

## Miscellaneous
- `./combine_mutation_analysis.R` - Combines multiple mutant data files into one.
- `./compare_final_orgs.R` - Very old script that tests multiple files to check which has the highest average merit.
