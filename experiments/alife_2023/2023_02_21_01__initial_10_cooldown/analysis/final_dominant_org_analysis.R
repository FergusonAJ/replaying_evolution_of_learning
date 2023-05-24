rm(list = ls())

library(ggplot2)
library(dplyr)

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_fiiles/shared_funcs__three_cues_one_set.R')
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# User defined variables
plot_dir = '../plots/'
data_dir = '../data/'

# Ensure directory structure is okay
if(!dir.exists(data_dir)){
  cat('Error! Data directory does not exist: ', data_dir, '\n')
  cat('Exiting.\n')
  quit(status = 1)
}
if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T, showWarnings = F)
processed_data_dir = paste0(data_dir, '/processed_data/') 
if(!dir.exists(processed_data_dir)) dir.create(processed_data_dir, recursive = T, showWarnings = F)

df = read.csv('../data/combined_final_dominant_data.csv')
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

write.csv(df, paste0(processed_data_dir, '/processed_full.csv'))
write.csv(df_summary, paste0(processed_data_dir, '/processed_summary.csv'))
write.csv(classification_summary, paste0(processed_data_dir, '/processed_classification.csv'))

df_summary = df_summary[order(df_summary$accuracy_mean),]
df_summary$seed_order = 1:nrow(df_summary)
ggplot(df_summary, aes(x = seed_order, color = seed_classification)) + 
  geom_point(aes(y = accuracy_mean)) +
  geom_point(aes(y = accuracy_min), alpha = 0.2) +
  geom_point(aes(y = accuracy_max), alpha = 0.2) +
  scale_color_manual(values = color_map) +
  xlab('Replicates (ordered)') +
  ylab('Accuracy') +
  labs(color = 'Classification')
ggsave(paste0(plot_dir, '/final_dom_accuracy.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_accuracy.png'), width = 9, height = 6, units = 'in')

df$seed_order = NA
for(seed in unique(df$seed)){
  df[df$seed == seed,]$seed_order = df_summary[df_summary$seed == seed,]$seed_order
}

ggplot(df, aes(x = seed_order, y = accuracy, color = seed_classification)) + 
  geom_point(alpha = 0.2) + 
  scale_color_manual(values = color_map) +
  xlab('Replicates (ordered)') +
  ylab('Accuracy') +
  labs(color = 'Classification') 
ggsave(paste0(plot_dir, '/final_dom_accuracy_spread.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_accuracy_spread.png'), width = 9, height = 6, units = 'in')

# Plot number of replicates classified as each category
ggplot(classification_summary, aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
  geom_col() + 
  geom_text(aes(y = count + 7, label = count), size = 4) + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Number of replicates') + 
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14))
ggsave(paste0(plot_dir, '/final_dom_classification.pdf'), width = 5, height = 5, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_classification.png'), width = 5, height = 5, units = 'in')

# Raincloud plot of accuracy
ggplot(df, aes(x = seed_classification_factor, y = accuracy, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Accuracy') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_accuracy.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_accuracy.png'), width = 9, height = 6, units = 'in')

# Raincloud plot of merit
ggplot(df, aes(x = seed_classification_factor, y = merit, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  scale_y_continuous(trans = 'log2') +
  xlab('Classification') + 
  ylab('Merit') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_merit.png'), width = 9, height = 6, units = 'in')

# Raincloud plot of genome length
ggplot(df_summary, aes(x = seed_classification_factor, y = genome_length, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Genome length') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_genome_length.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_genome_length.png'), width = 9, height = 6, units = 'in')

# Raincloud plot of mean accuracy of replicates
ggplot(df_summary, aes(x = seed_classification_factor, y = accuracy_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  scale_y_continuous(limits = c(0,1)) +
  xlab('Classification') + 
  ylab('Mean accuracy') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_accuracy.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_accuracy.png'), width = 9, height = 6, units = 'in')

# Raincloud plot of mean merit of replicates
ggplot(df_summary, aes(x = seed_classification_factor, y = merit_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Mean merit') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_merit.png'), width = 9, height = 6, units = 'in')

ggplot(df_summary, aes(x = seed_classification_factor, y = merit_max, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Max merit') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_max_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_max_merit.png'), width = 9, height = 6, units = 'in')

ggplot(df_summary, aes(x = seed_classification_factor, y = merit_median, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Median merit') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_median_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_median_merit.png'), width = 9, height = 6, units = 'in')

ggplot(df_summary, aes(x = seed_classification_factor, y = correct_doors_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Correct doors (mean)') + 
  theme(legend.position = 'none')

print('Learning reps:')
sort(df_summary[df_summary$seed_classification == seed_class_learning,]$seed)
print('Bet-hedged imprinting reps:')
sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed)
print('Error correction reps:')
sort(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed)
print('Bet-hedged error correction reps:')
sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)
print('Other reps:')
sort(df_summary[df_summary$seed_classification == seed_class_other,]$seed)
print('Small reps:')
sort(df_summary[df_summary$seed_classification == seed_class_small,]$seed)

image_sorting_str = ''
# Learning
if(length(df_summary[df_summary$seed_classification == seed_class_learning,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str,  'mkdir -p learning\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_learning,]$seed)){
  image_sorting_str = paste0(image_sorting_str,  'mv rep_', seed, '.png learning;\n')
}
# Bet-hedged imprinting
if(length(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p bet_hedged_imprinting\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png bet_hedged_imprinting;\n')
}
# Error correction
if(length(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p error_correction\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png error_correction;\n')
}
# Bet-hedged error correction
if(length(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p bet_hedged_error_correction\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png bet_hedged_error_correction;\n')
}
# Mixed bet-hedging
if(length(df_summary[df_summary$seed_classification == seed_class_bet_hedged_mixed,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p mixed_bet_hedging\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_mixed,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png mixed_bet_hedging;\n')
}
if(length(df_summary[df_summary$seed_classification == seed_class_small,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p small\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_small,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png small;\n')
}
cat(image_sorting_str)
image_sorting_str = paste0('#!/bin/bash\n\n', image_sorting_str)
image_dir = '../images'
if(!dir.exists(image_dir)){
  dir.create(image_dir)
}
sorting_script_filename = paste0(image_dir, '/sort.sh')
write(image_sorting_str, sorting_script_filename)
cat('Saved sorting script to: ', sorting_script_filename, '\n')

ggplot(df_summary, aes(x = merit_mean)) + 
  geom_histogram() + 
  scale_x_continuous(trans = 'log2')
