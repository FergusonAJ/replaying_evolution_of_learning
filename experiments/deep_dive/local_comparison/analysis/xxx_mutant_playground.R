rm(list = ls())

library(ggplot2)

# Local include
source('./local_setup.R')

seed = 93
true_seed = 93
#df_lineage = read.csv(paste0('../data/processed_data/reps/', seed, '/processed_lineage.csv'))
#
#first_learning_depth = min(df_lineage[df_lineage$seed_classification == seed_class_learning,]$depth)
#first_learning_merit_mean = df_lineage[df_lineage$depth == first_learning_depth,]$merit_mean
#focal_depth = first_learning_depth - 1

df_replays = read.csv('../../local_comparison/data/targeted_replay_data_analyzed.csv')
df_replays = df_replays[df_replays$is_largest_potentiation_gain & df_replays$seed == true_seed,]
focal_merit_mean = df_replays$merit_mean_mean
focal_depth = df_replays$depth - 1

df_mut = read.csv(paste0('../data/reps/', seed, '/mutants/', focal_depth, '/one_step_mut_summary_1.csv'))

df_mut$diff_class = 'Smaller'
df_mut[df_mut$merit_mean > first_learning_merit_mean,]$diff_class = 'Larger'
df_mut[df_mut$merit_mean > first_learning_merit_mean * 32,]$diff_class = 'Much larger'


ggplot(df_mut, aes(x = merit_mean)) + 
  geom_vline(xintercept = first_learning_merit_mean, linetype = 'dashed') +
  geom_histogram(bins = 200) + 
  scale_x_log10()

ggplot(df_mut, aes(x = merit_mean, fill = as.factor(diff_class))) + 
  geom_vline(xintercept = first_learning_merit_mean, linetype = 'dashed') +
  geom_histogram(bins = 50) + 
  scale_x_log10()
