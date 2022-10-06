rm(list = ls())

library(ggplot2)
library(dplyr)

source('../../../../global_shared_files/constant_vars__two_cues.R')
source('../../../../global_shared_files/shared_funcs__two_cues.R')
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

plot_dir = '../plots/'
if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T, showWarnings = F)

df = NA
df_summary = NA
classification_summary = NA

for(cue_str in c('2c', '3c1s')){
  if(cue_str == '2c'){
    source('../../../../global_shared_files/constant_vars__two_cues.R')
    source('../../../../global_shared_files/shared_funcs__two_cues.R')
  } else {
    source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
    source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')
  }
  for(penalty_str in c('1', '1_1', '1_25', '1_5', '2')){
    filename = paste0('../../2022_08_15__', cue_str, '_penalty_', penalty_str, '/data/combined_final_dominant_data.csv')
    if(!file.exists(filename)){
      print(paste0('Cannot find file: ', filename))
      quit()
    }
    print(paste0('Processing: ', filename))
    penalty = as.numeric(gsub('_', '.', penalty_str))
    df_tmp = read.csv(filename)
    df_tmp = classify_individual_trials(df_tmp)
    df_tmp = classify_seeds(df_tmp)
    df_tmp$cues = cue_str 
    df_tmp$penalty = penalty
    if(cue_str == '2c'){
      df_tmp$doors_correct_3 = NA
      df_tmp$doors_taken_3 = NA
      df_tmp$doors_incorrect_3 = NA
    }
    df_summary_tmp = summarize_final_dominant_org_data(df_tmp)
    df_summary_tmp$cues = cue_str
    df_summary_tmp$penalty = penalty
    classification_summary_tmp = summarize_classifications(df_summary_tmp)
    classification_summary_tmp$cues = cue_str
    classification_summary_tmp$penalty = penalty
    if(!is.data.frame(df)){
      df = df_tmp
      df_summary = df_summary_tmp
      classification_summary = classification_summary_tmp
    } else {
      df = rbind(df, df_tmp)
      df_summary = rbind(df_summary, df_summary_tmp)
      classification_summary = rbind(classification_summary, classification_summary_tmp)
      
    }
  }
}

# Plot number of replicates classified as each category
ggplot(classification_summary, aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
  geom_col() + 
  geom_text(aes(y = count + 3, label = count)) + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Number of replicates') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(cues), cols = vars(penalty)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/final_dom_classification.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_classification.png'), width = 9, height = 6, units = 'in')

#ggplot(df_summary, aes(x = seed_order, color = seed_classification)) + 
#  geom_point(aes(y = accuracy_mean)) +
#  geom_point(aes(y = accuracy_min), alpha = 0.2) +
#  geom_point(aes(y = accuracy_max), alpha = 0.2) +
#  scale_color_manual(values = color_map) +
#  xlab('Replicates (ordered)') +
#  ylab('Accuracy') +
#  labs(color = 'Classification')
#ggsave(paste0(plot_dir, '/final_dom_accuracy.pdf'), width = 9, height = 6, units = 'in')
#ggsave(paste0(plot_dir, '/final_dom_accuracy.png'), width = 9, height = 6, units = 'in')
#
#df$seed_order = NA
#for(seed in unique(df$seed)){
#  df[df$seed == seed,]$seed_order = df_summary[df_summary$seed == seed,]$seed_order
#}
#
#ggplot(df, aes(x = seed_order, y = accuracy, color = seed_classification)) + 
#  geom_point(alpha = 0.2) + 
#  scale_color_manual(values = color_map) +
#  xlab('Replicates (ordered)') +
#  ylab('Accuracy') +
#  labs(color = 'Classification') 
#ggsave(paste0(plot_dir, '/final_dom_accuracy_spread.pdf'), width = 9, height = 6, units = 'in')
#ggsave(paste0(plot_dir, '/final_dom_accuracy_spread.png'), width = 9, height = 6, units = 'in')
#
#
## Raincloud plot of accuracy
#ggplot(df, aes(x = seed_classification_factor, y = accuracy, fill = seed_classification_factor)) + 
#  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
#  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
#  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
#  scale_fill_manual(values = color_map) +
#  scale_color_manual(values = color_map) + 
#  xlab('Classification') + 
#  ylab('Accuracy') + 
#  theme(legend.position = 'none')
#ggsave(paste0(plot_dir, '/raincloud_accuracy.pdf'), width = 9, height = 6, units = 'in')
#ggsave(paste0(plot_dir, '/raincloud_accuracy.png'), width = 9, height = 6, units = 'in')
#
# Raincloud plot of merit
ggplot(df, aes(x = seed_classification_factor, y = merit, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Merit') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(cues), cols = vars(penalty)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/raincloud_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_merit.png'), width = 9, height = 6, units = 'in')
#
## Raincloud plot of genome length
#ggplot(df_summary, aes(x = seed_classification_factor, y = genome_length, fill = seed_classification_factor)) + 
#  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
#  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
#  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
#  scale_fill_manual(values = color_map) +
#  scale_color_manual(values = color_map) + 
#  xlab('Classification') + 
#  ylab('Genome length') + 
#  theme(legend.position = 'none')
#ggsave(paste0(plot_dir, '/raincloud_genome_length.pdf'), width = 9, height = 6, units = 'in')
#ggsave(paste0(plot_dir, '/raincloud_genome_length.png'), width = 9, height = 6, units = 'in')
#
## Raincloud plot of mean accuracy of replicates
#ggplot(df_summary, aes(x = seed_classification_factor, y = accuracy_mean, fill = seed_classification_factor)) + 
#  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
#  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
#  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
#  scale_fill_manual(values = color_map) +
#  scale_color_manual(values = color_map) + 
#  scale_y_continuous(limits = c(0,1)) +
#  xlab('Classification') + 
#  ylab('Mean accuracy') + 
#  theme(legend.position = 'none')
#ggsave(paste0(plot_dir, '/raincloud_rep_accuracy.pdf'), width = 9, height = 6, units = 'in')
#ggsave(paste0(plot_dir, '/raincloud_rep_accuracy.png'), width = 9, height = 6, units = 'in')
#
## Raincloud plot of mean merit of replicates
#ggplot(df_summary, aes(x = seed_classification_factor, y = merit_mean, fill = seed_classification_factor)) + 
#  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
#  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
#  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
#  scale_fill_manual(values = color_map) +
#  scale_color_manual(values = color_map) + 
#  xlab('Classification') + 
#  ylab('Mean merit') + 
#  theme(legend.position = 'none')
#ggsave(paste0(plot_dir, '/raincloud_rep_merit.pdf'), width = 9, height = 6, units = 'in')
#ggsave(paste0(plot_dir, '/raincloud_rep_merit.png'), width = 9, height = 6, units = 'in')
#
#
#print('Learning reps:')
#sort(df_summary[df_summary$seed_classification == seed_class_learning,]$seed)
#print('Bet-hedged imprinting reps:')
#sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed)
#print('Error correction reps:')
#sort(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed)
#print('Bet-hedged error correction reps:')
#sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)
#print('Other reps:')
#sort(df_summary[df_summary$seed_classification == seed_class_other,]$seed)
#print('Small reps:')
#sort(df_summary[df_summary$seed_classification == seed_class_small,]$seed)
