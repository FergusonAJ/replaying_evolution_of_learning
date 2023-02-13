rm(list = ls())

library(ggplot2)
library(dplyr)

# If we're in RStudio (i.e., local), hardcode directories
if(Sys.getenv("RSTUDIO") == 1){
  script_dir = '../../../../global_shared_files'
  input_dir = '../data' 
  output_dir = '../data/'
  seed = 28
  depth = 391
  mut_job_id = 1
} else { # Else pull from command line args
  args = commandArgs(trailingOnly=TRUE)
  if(length(args) < 6){
    cat('Error! local_mutation_analysis.R expects exactly 6 command line arguments:\n')
    cat('    1. The directory holding the other scripts (e.g., the 3c1s constant variable script)\n')
    cat('    2. The input directory\n')
    cat('    3. The output directory\n')
    cat('    4. The seed of the *original* replicate\n')
    cat('    5. The depth along the lineage we are analyzing\n')
    cat('    6. Slurm job ID we are analying\n')
  }
  script_dir = args[1]
  input_dir = args[2]
  output_dir = args[3]
  seed = as.numeric(args[4])
  depth = as.numeric(args[5])
  mut_job_id = as.numeric(args[6])
}

# Load in necessary variables and functions
source(paste0(script_dir, '/constant_vars__three_cues_one_set.R'))
source(paste0(script_dir, '/shared_funcs__three_cues_one_set.R'))

# Load raw data
input_filename = paste0(input_dir, '/reps/', seed, '/mutants/', depth, '/mutant_data_', mut_job_id, '.csv')
df = read.csv(input_filename)

# Swap doors 1 and 3 because of historical contingency
df$doors_correct_tmp = df$doors_correct_3
df$doors_taken_tmp = df$doors_taken_3
df$doors_correct_3 = df$doors_correct_1
df$doors_taken_3 = df$doors_taken_1
df$doors_correct_1 = df$doors_correct_tmp
df$doors_taken_1 = df$doors_taken_tmp
# Create new variable for grouping
df$seed = paste0(df$one_step_mut_seed, 'x', df$two_step_mut_seed) 

# Analyze! (takes a while)
df = classify_individual_trials(df)
df = classify_seeds(df)
df_summary = summarize_final_dominant_org_data(df)
classification_summary = summarize_classifications(df_summary)

# Extract one step mutants
df_one_step = df[df$two_step_mut_seed == -1,]
df_one_step_summary = summarize_final_dominant_org_data(df_one_step)
df_one_step_classification = summarize_classifications(df_one_step_summary)


# Write output
full_output_dir = paste0(output_dir, '/reps/', seed, '/mutants/', depth)
## Classification
classification_filename = paste0(full_output_dir, 'mut_classification_', mut_job_id, '.csv')
write.csv(classification_summary, classification_filename)
## One-step summary
one_step_summary_filename = paste0(full_output_dir, 'one_step_mut_summary_', mut_job_id, '.csv')
write.csv(df_one_step_summary, one_step_summary_filename)
## One step classification
one_step_classification_filename = paste0(full_output_dir, 'one_step_classification_', mut_job_id, '.csv')
write.csv(df_one_step_classification, one_step_classification_filename)
