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

cooldown_vec = c('0', '10', '20', '30', '50')
genome_length_vec = c(50, 100)
for(genome_length in genome_length_vec){
  genome_length_str = ''
  if(genome_length == 100){
    genome_length_str = '_len_100'
  }
  for(cue_str in c('3c1s')){
    if(cue_str == '2c'){
      source('../../../../global_shared_files/constant_vars__two_cues.R')
      source('../../../../global_shared_files/shared_funcs__two_cues.R')
    } else {
      source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
      source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')
    }
    for(cooldown_str in cooldown_vec){
      filename = paste0('../../2022_10_06__', cue_str, '_exit_cooldown_', cooldown_str, genome_length_str, '/data/combined_final_dominant_data.csv')
      if(!file.exists(filename)){
        print(paste0('Cannot find file: ', filename))
        next #quit()
      }
      print(paste0('Processing: ', filename))
      df_tmp = read.csv(filename)
      df_tmp = classify_individual_trials(df_tmp)
      df_tmp = classify_seeds(df_tmp)
      df_tmp$cues = cue_str
      df_tmp$exit_cooldown = as.numeric(cooldown_str) 
      df_tmp$initial_genome_length = genome_length
      if(cue_str == '2c'){
        df_tmp$doors_correct_3 = NA
        df_tmp$doors_taken_3 = NA
        df_tmp$doors_incorrect_3 = NA
      }
      df_summary_tmp = summarize_final_dominant_org_data(df_tmp)
      df_summary_tmp$cues = cue_str
      df_summary_tmp$exit_cooldown = as.numeric(cooldown_str)
      df_summary_tmp$initial_genome_length = genome_length
      classification_summary_tmp = summarize_classifications(df_summary_tmp)
      classification_summary_tmp$cues = cue_str
      classification_summary_tmp$exit_cooldown = as.numeric(cooldown_str) 
      classification_summary_tmp$initial_genome_length = genome_length
      if(!is.data.frame(df)){
        df = df_tmp
        df_summary = df_summary_tmp
        classification_summary = classification_summary_tmp
      } else {
        df = rbind(df, df_tmp)
        df_summary = rbind(df_summary, df_summary_tmp)
        classification_summary = rbind(classification_summary, classification_summary_tmp)
      }
      cat('Unique seeds found: ', length(unique(df_summary_tmp$seed)), '\n')
    }
  }
}
if(!dir.exists('../data')){ dir.create('../data') }
write.csv(df, '../data/combined_df.csv')
write.csv(df_summary, '../data/combined_df_summary.csv')
write.csv(classification_summary, '../data/combined_classification_summary.csv')


# Plot number of replicates classified as each category
ggplot(classification_summary, aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
  geom_col() + 
  geom_text(aes(y = count + 3, label = count)) + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Number of replicates') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(initial_genome_length), cols = vars(exit_cooldown)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/final_dom_classification.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_classification.png'), width = 9, height = 6, units = 'in')

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
  facet_grid(rows = vars(initial_genome_length), cols = vars(exit_cooldown)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/raincloud_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_merit.png'), width = 9, height = 6, units = 'in')

# Raincloud plot of accuracy 
ggplot(df, aes(x = seed_classification_factor, y = accuracy, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Accuracy') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(initial_genome_length), cols = vars(exit_cooldown)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/raincloud_accuracy.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_accuracy.png'), width = 9, height = 6, units = 'in')

# Raincloud of *mean* accuracy
ggplot(df_summary, aes(x = seed_classification_factor, y = accuracy_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  scale_y_continuous(limits = c(0,1)) +
  xlab('Classification') + 
  ylab('Accuracy') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(initial_genome_length), cols = vars(exit_cooldown)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/raincloud_mean_accuracy.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_mean_accuracy.png'), width = 9, height = 6, units = 'in')

# Raincloud plot of doors correct
ggplot(df, aes(x = seed_classification_factor, y = door_rooms, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Doors Correct') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(initial_genome_length), cols = vars(exit_cooldown)) +
  theme(axis.text.x = element_blank())

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(exit_cooldown), y = merit, fill = as.factor(initial_genome_length))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(initial_genome_length)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Correct') + 
  theme(legend.position = 'bottom')

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(exit_cooldown), y = correct_doors, fill = as.factor(initial_genome_length))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(initial_genome_length)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Incorrect') + 
  theme(legend.position = 'bottom')
ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(exit_cooldown), y = incorrect_doors, fill = as.factor(initial_genome_length))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(initial_genome_length)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Incorrect') + 
  theme(legend.position = 'bottom')

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(exit_cooldown), y = incorrect_exits, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Exits Incorrect') + 
  theme(legend.position = 'bottom')

ggplot(df_summary, aes(x = as.factor(exit_cooldown), y = genome_length, fill = as.factor(initial_genome_length))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(initial_genome_length)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom')

ggplot(df, aes(x = as.factor(exit_cooldown), y = accuracy, fill = as.factor(initial_genome_length))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(initial_genome_length)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom')

ggplot(df_summary, aes(x = as.factor(exit_cooldown), y = accuracy_mean, fill = as.factor(initial_genome_length))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(initial_genome_length)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom')

df_tmp = df[df$cues == '3c1s' & df$seed_classification == seed_class_other,]
