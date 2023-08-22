rm(list = ls())

library(ggplot2)
library(dplyr)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Plot!
if(plot_dir == '../plots/'){
  plot_dir = paste0(plot_dir, 'initial_replicates/')
}
create_dir_if_needed(plot_dir)

raw_dirs = list.dirs('../..', recursive = F)
dir_vec = raw_dirs[grep('2023', raw_dirs)]

df = NA
for(dir_path in dir_vec){
  filename = paste0(dir_path, '/data/processed_data/processed_summary.csv')
  if(!file.exists(filename)){
    cat('File does not exist:', filename, '\n')
    next
  }
  df_dir = read.csv(filename)
  cat(dir_path, sum(df_dir$count), '\n')
  df_dir$dir = dir_path
  if(is.data.frame(df)){
    df = rbind(df, df_dir)
  } else {
    df = df_dir
  }
}
df$log_merit_mean = log(df$merit_mean, 2)
df$efficiency_mean = df$merit_mean / df$repro_updates_mean
df$efficiency_log_mean = df$log_merit_mean / df$repro_updates_mean

# Plot number of replicates classified as each category
ggplot(df, aes(x = seed_classification_factor, y = merit_mean, fill = seed_classification_factor)) +
  geom_boxplot() +
  xlab('Classification') +
  ylab('Mean merit') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_fill_manual(values = color_map) +
  scale_y_log10()

# Plot number of replicates classified as each category
ggplot(df, aes(x = seed_classification_factor, y = log_merit_mean, fill = seed_classification_factor)) +
  geom_boxplot() +
  xlab('Classification') +
  ylab('Log mean merit') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_fill_manual(values = color_map)

ggplot(df, aes(x = seed_classification_factor, y = merit_mean / repro_updates_mean, fill = seed_classification_factor)) +
  geom_boxplot() +
  xlab('Classification') +
  ylab('Mean efficiency') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_fill_manual(values = color_map) +
  scale_y_log10()

ggplot(df, aes(x = seed_classification_factor, y = log_merit_mean / repro_updates_mean, fill = seed_classification_factor)) +
  geom_boxplot() +
  xlab('Classification') +
  ylab('Mean efficiency') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_fill_manual(values = color_map)
  
ggplot(df, aes(x = seed_classification_factor, y = merit_mean / repro_updates_mean, fill = seed_classification_factor)) +
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map) + 
    xlab('Classification') +
    ylab('Mean efficiency') +
    theme(legend.position = 'none') + 
    scale_y_log10()

ggplot(df, aes(x = repro_updates_mean, y = merit_mean, color = seed_classification_factor)) +
  geom_point(alpha = 0.5) +
  xlab('Mean repro time') +
  ylab('Mean merit') +
  theme(legend.position = 'none') +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_color_manual(values = color_map) +
  scale_y_log10()

ggplot(df, aes(x = repro_updates_mean, y = merit_mean, color = seed_classification_factor)) +
  geom_point(alpha = 0.5) +
  xlab('Mean repro time') +
  ylab('Mean merit') +
  theme(legend.position = 'none') +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_color_manual(values = color_map) +
  scale_y_log10() + 
  facet_wrap(vars(seed_classification_factor))

ggplot(df[df$repro_updates_mean < 2000,], aes(x = repro_updates_mean, y = merit_mean, color = seed_classification_factor)) +
  geom_point(alpha = 0.5) +
  xlab('Mean repro time') +
  ylab('Mean merit') +
  theme(legend.position = 'none') +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_color_manual(values = color_map) +
  scale_y_log10() + 
  facet_wrap(vars(seed_classification_factor))

# Plot number of replicates classified as each category
ggplot(df, aes(x = seed_classification_factor, y = accuracy_mean, fill = seed_classification_factor)) +
  geom_boxplot() +
  xlab('Classification') +
  ylab('Mean accuracy') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_fill_manual(values = color_map)

ggplot(df[,], aes(x = accuracy_mean, y = merit_mean, color = seed_classification_factor)) +
  geom_point(alpha = 0.5) +
  xlab('Mean accuracy') +
  ylab('Mean merit') +
  theme(legend.position = 'none') +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14)) + 
  scale_color_manual(values = color_map) +
  scale_y_log10() + 
  facet_wrap(vars(seed_classification_factor))

