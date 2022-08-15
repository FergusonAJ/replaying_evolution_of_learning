rm(list = ls())

library(ggplot2)
library(dplyr)

source('./constant_vars.R')
source('./shared_funcs.R')
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

plot_dir = '../plots/'
if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T, showWarnings = F)

df = read.csv('../data/combined_final_dominant_data.csv')
df = classify_individual_trials(df)
df = classify_seeds(df)
df_summary = summarize_final_dominant_org_data(df)
classification_summary = summarize_classifications(df_summary)

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
  geom_text(aes(y = count + 3, label = count)) + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Number of replicates') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/final_dom_classification.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_classification.png'), width = 9, height = 6, units = 'in')

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
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Mean merit') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_merit.png'), width = 9, height = 6, units = 'in')


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
