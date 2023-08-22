rm(list = ls())

library(ggplot2)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# Local include
source('./local_setup.R')

# Load processed data
df = load_processed_data()
df_summary = load_processed_summary()
classification_summary = load_processed_classification()

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
  #scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Correct doors (mean)') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_correct_doors_mean.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_correct_doors_mean.png'), width = 9, height = 6, units = 'in')

ggplot(df_summary, aes(x = seed_classification_factor, y = incorrect_doors_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  #scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Incorrect doors (mean)') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_incorrect_doors_mean.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_incorrect_doors_mean.png'), width = 9, height = 6, units = 'in')

ggplot(df_summary, aes(x = seed_classification_factor, y = repro_updates_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Repro updates (mean)') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/raincloud_rep_repro_updates_mean.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_rep_repro_updates_mean.png'), width = 9, height = 6, units = 'in')


ggplot(df_summary, aes(x = correct_doors_mean, y = incorrect_doors_mean, color = seed_classification_factor)) + 
  geom_point() +
  scale_color_manual(values = color_map)

ggplot(df_summary, aes(x = correct_doors_mean, y = repro_updates_mean, color = seed_classification_factor)) + 
  geom_point() +
  scale_color_manual(values = color_map)

ggplot(df_summary, aes(x = seed_classification_factor, y = merit_mean / repro_updates_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Merit / Repro updates') + 
  theme(legend.position = 'none')

ggplot(df_summary, aes(x = merit_mean)) + 
  geom_histogram() + 
  scale_x_continuous(trans = 'log2')


df_tmp = data.frame(data = matrix(nrow = 0, ncol = 5))
df$log_merit = log(df$merit, 2)
for(seed in unique(df$seed)){
  seed_mean = mean(df[df$seed == seed,]$log_merit)
  seed_sd = sd(df[df$seed == seed,]$log_merit)
  seed_median = median(df[df$seed == seed,]$log_merit)
  seed_classification = df[df$seed == seed,]$seed_classification[1]
  df_tmp[nrow(df_tmp) + 1,] = c(seed, seed_classification, seed_mean, seed_median, seed_sd)
}
colnames(df_tmp) = c('seed', 'seed_classification', 'seed_mean', 'seed_median', 'seed_sd')
df_tmp$seed_mean = as.numeric(df_tmp$seed_mean)
df_tmp$seed_median = as.numeric(df_tmp$seed_median)
df_tmp$seed_sd = as.numeric(df_tmp$seed_sd)

ggplot(df_tmp, aes(x = seed_mean, seed_sd)) + 
  geom_point(aes(color = as.factor(seed_classification)))
