rm(list = ls())

library(ggplot2)
library(dplyr)

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

plot_dir = '../plots/'
if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T, showWarnings = F)

df = read.csv('/media/austin/samsung_nvme_pop/research/learning/replaying_evolution_of_learning/experiments/exploration/2023_01_26_04__oft_cooldown_step_4/mock_scratch/2023_01_26_04__oft_cooldown_step_4/reps/1/single_org_fitness.csv')
df$seed = df$mut_seed
cat('Unique seeds: ', length(unique(df$seed)))
# We switched doors 1 and 3 here
df$doors_correct_tmp = df$doors_correct_3
df$doors_taken_tmp = df$doors_taken_3
df$doors_correct_3 = df$doors_correct_1
df$doors_taken_3 = df$doors_taken_1
df$doors_correct_1 = df$doors_correct_tmp
df$doors_taken_1 = df$doors_taken_tmp
df = classify_individual_trials(df)
df = classify_seeds(df)
df_summary = summarize_final_dominant_org_data(df)
classification_summary = summarize_classifications(df_summary)

ggplot(df_summary, aes(x = seed_classification_factor, y = merit_median)) + 
  geom_jitter() + 
  scale_y_continuous(trans = 'log')
