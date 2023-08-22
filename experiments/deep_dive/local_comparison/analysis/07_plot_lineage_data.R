rm(list = ls())

library(ggplot2)

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'targeted_replay_data_analyzed.csv')
df = read.csv(base_data_filename)
summary_filename = paste0(data_dir, 'targeted_replay_analysis_summary.csv')
df_summary = read.csv(summary_filename)
lineage_filename = '../data/combined_lineage_data.csv'
df_lineage = read.csv(lineage_filename)

ggplot(df_lineage, aes(x = depth, y = merit_mean, group = true_seed)) + 
  geom_line() + 
  scale_y_log10() + 
  facet_wrap(vars(true_seed))


df_lineage$is_largest_potentiation_increase = F
df_lineage$focal_potentiation_depth = NA
df_lineage$focal_potentiation_merit_mean = NA
for(true_seed in unique(df_summary$true_seed)){
  depth_of_largest_step = df[df$true_seed == true_seed & df$is_learning & df$is_largest_potentiation_gain,]$depth
  df_lineage[df_lineage$true_seed == true_seed & df_lineage$depth == depth_of_largest_step,]$is_largest_potentiation_increase = T
  df_lineage[df_lineage$true_seed == true_seed,]$focal_potentiation_depth = depth_of_largest_step
  df_lineage[df_lineage$true_seed == true_seed,]$focal_potentiation_merit_mean = df_lineage[df_lineage$true_seed == true_seed & df_lineage$depth == depth_of_largest_step,]$merit_mean
}
df_lineage$relative_potentiation_depth = df_lineage$focal_potentiation_depth - df_lineage$depth
df_lineage$relative_potentiation_merit_mean = df_lineage$focal_potentiation_merit_mean / df_lineage$merit_mean

ggplot(df_lineage[df_lineage$relative_potentiation_depth %in% -25:25,], aes(x = relative_potentiation_depth, y = relative_potentiation_merit_mean, group = true_seed)) + 
  geom_line() + 
  geom_point(data = df_lineage[df_lineage$is_largest_potentiation_increase,], color = '#aa3300') +
  scale_y_log10() + 
  facet_wrap(vars(true_seed))

ggplot(df_lineage[df_lineage$relative_potentiation_depth %in% -1:0,], aes(x = relative_potentiation_depth, y = relative_potentiation_merit_mean, group = true_seed)) + 
  geom_line() + 
  geom_point(data = df_lineage[df_lineage$is_largest_potentiation_increase,], color = '#aa3300') +
  scale_y_log10() + 
  facet_wrap(vars(true_seed))

ggplot(df_lineage[df_lineage$relative_potentiation_depth == -1 & df_lineage$relative_potentiation_merit_mean > 0.1,], aes(x = 1, y = 1/relative_potentiation_merit_mean)) + 
  geom_hline(yintercept = 1, linetype='dashed') +
  annotate('rect', xmin = 0, xmax = 2, ymin = 0.5, ymax = 1.5, fill = '#33aa00', alpha = 0.5) +
  geom_jitter()

df_lineage$first_learning_depth = NA
for(true_seed in unique(df_summary$true_seed)){
  learning_depth = min(df_lineage[df_lineage$true_seed == true_seed & df_lineage$seed_classification == seed_class_learning,]$depth)
  df_lineage[df_lineage$true_seed == true_seed,]$first_learning_depth = learning_depth 
}

ggplot(df_lineage[df_lineage$depth == df_lineage$focal_potentiation_depth,], aes(x = first_learning_depth - focal_potentiation_depth)) +
  geom_histogram(binwidth = 100)

df_lineage_potentiation$relative_learning_depth = df_lineage_potentiation$first_learning_depth - df_lineage_potentiation$focal_potentiation_depth
sort(df_lineage_potentiation$relative_learning_depth)

