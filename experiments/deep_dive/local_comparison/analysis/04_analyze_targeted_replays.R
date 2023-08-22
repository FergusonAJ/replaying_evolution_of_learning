rm(list = ls())

library(dplyr)

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'targeted_replay_data_base.csv')
df = read.csv(base_data_filename)

# General masks
learning_mask = df$is_learning

# Normalize based on first learning depth
df$first_learning_depth = NA
df$target_window_potentiation_diff = NA
df$is_largest_potentiation_gain = F
df$lineage_merit_mean_diff = NA
df$lineage_merit_mean_frac = NA
df$prev_lineage_classification = NA
for(true_seed in unique(df$true_seed)){
  true_seed_mask = df$true_seed == true_seed
  learning_depth = max(df[true_seed_mask,]$depth)
  df[true_seed_mask,]$first_learning_depth = learning_depth
  cat(true_seed, ' ')
  for(target_window_depth in unique(df[true_seed_mask,]$target_window_depth)){
    if(target_window_depth == 0){
      next
    }
    df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$target_window_potentiation_diff = 
      df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$frac -
      df[true_seed_mask & df$target_window_depth == (target_window_depth - 1) & df$is_learning,]$frac
    df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$lineage_merit_mean_diff = 
      df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$lineage_merit_mean -
      df[true_seed_mask & df$target_window_depth == (target_window_depth - 1) & df$is_learning,]$lineage_merit_mean
    df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$lineage_merit_mean_frac = 
      df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$lineage_merit_mean /
      df[true_seed_mask & df$target_window_depth == (target_window_depth - 1) & df$is_learning,]$lineage_merit_mean
    df[true_seed_mask & df$target_window_depth == target_window_depth & df$is_learning,]$prev_lineage_classification = 
      df[true_seed_mask & df$target_window_depth == (target_window_depth - 1) & df$is_learning,]$lineage_classification
  }
  max_potentiation_diff = max(df[true_seed_mask,]$target_window_potentiation_diff, na.rm = T)
  df[true_seed_mask & !is.na(df$target_window_potentiation_diff) & df$target_window_potentiation_diff == max_potentiation_diff,]$is_largest_potentiation_gain = T
}
cat('\n')
df$depth_frac = df$depth / df$first_learning_depth

filename = paste0(data_dir, 'targeted_replay_data_analyzed.csv')
write.csv(df, filename, row.names = F)

# Summarize data
df_grouped = dplyr::group_by(df, true_seed)
df_summary = dplyr::summarize(df_grouped, 
                              max_potentiation_diff = max(target_window_potentiation_diff, na.rm = T),
                              min_potentiation_diff = min(target_window_potentiation_diff, na.rm = T))
summary_filename = paste0(data_dir, 'targeted_replay_analysis_summary.csv')
write.csv(df_summary, summary_filename, row.names = F)
