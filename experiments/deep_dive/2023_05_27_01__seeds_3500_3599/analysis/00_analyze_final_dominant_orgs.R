rm(list = ls())

library(dplyr)

# Local include
source('./local_setup.R')

# Load data
df = read.csv('../data/combined_final_dominant_data.csv')
cat('Unique seeds: ', length(unique(df$seed)), '\n')

# We switched doors 1 and 3 in that here, so revert that here
df$doors_correct_tmp = df$doors_correct_3
df$doors_taken_tmp = df$doors_taken_3
df$doors_correct_3 = df$doors_correct_1
df$doors_taken_3 = df$doors_taken_1
df$doors_correct_1 = df$doors_correct_tmp
df$doors_taken_1 = df$doors_taken_tmp

# Process data
df = classify_individual_trials(df)
df = classify_seeds(df)
df_summary = summarize_final_dominant_org_data(df)
classification_summary = summarize_classifications(df_summary)

# Order seeds
df_summary = df_summary[order(df_summary$accuracy_mean),]
df_summary$seed_order = 1:nrow(df_summary)
df$seed_order = NA
for(seed in unique(df$seed)){
  df[df$seed == seed,]$seed_order = df_summary[df_summary$seed == seed,]$seed_order
}

# Annotate summary
df_summary$process_annotations = 'a:00'

write.csv(df, paste0(processed_data_dir, '/processed_full.csv'), row.names = F)
write.csv(df_summary, paste0(processed_data_dir, '/processed_summary.csv'), row.names = F)
write.csv(classification_summary, paste0(processed_data_dir, '/processed_classification.csv'), row.names = F)