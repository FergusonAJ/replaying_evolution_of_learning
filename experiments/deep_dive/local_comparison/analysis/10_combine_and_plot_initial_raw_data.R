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
seed_offset = 0
for(dir_path in dir_vec){
  filename = paste0(dir_path, '/data/processed_data/processed_full.csv')
  if(!file.exists(filename)){
    cat('File does not exist:', filename, '\n')
    next
  }
  df_dir = read.csv(filename)
  df_dir$dir = dir_path
  df_dir$true_seed = df_dir$seed + seed_offset
  seed_offset = seed_offset + 500
  if(is.data.frame(df)){
    df = rbind(df, df_dir)
  } else {
    df = df_dir
  }
}

df$log_merit = log(df$merit, 2)
df$efficiency = df$log_merit / df$repro_updates

df_tmp = df %>%
  dplyr::group_by(true_seed) %>%
  dplyr::summarize(
    seed_classification = first(seed_classification),
    seed_mean = mean(log_merit),
    seed_median = median(log_merit),
    seed_sd = sd(log_merit),
    seed_efficiency_mean = mean(efficiency),
    seed_efficiency_median = median(efficiency),
    seed_efficiency_sd = sd(efficiency),
  )

ggplot(df_tmp, aes(x = seed_mean, seed_sd)) + 
  geom_point(aes(color = as.factor(seed_classification)), alpha = 0.5) + 
  scale_color_manual(values = color_map) + 
  facet_wrap(vars(seed_classification))

df_learning = df_tmp[df_tmp$seed_classification == seed_class_learning,]
cat('Min sd:', min(df_learning$seed_sd), '\n')
cat('Max sd:', max(df_learning$seed_sd), '\n')
cat('Mean sd:', mean(df_learning$seed_sd), '\n')
cat('Median sd:', median(df_learning$seed_sd), '\n')
cat('SD sd:', sd(df_learning$seed_sd), '\n')


max_seed = max(unique(df$true_seed))
all_seeds = 1:max_seed
missing_seeds = all_seeds[!(all_seeds %in% unique(df$true_seed))]
cat('Missing seeds: ', missing_seeds, '\n')
write(missing_seeds, paste0(data_dir, '/missing_seeds.txt'))

ggplot(df, aes(x = repro_updates, y = merit)) + 
  geom_point(alpha = 0.2) + 
  scale_y_log10() + 
  facet_wrap(vars(seed_classification))

ggplot(df_tmp, aes(x = seed_efficiency_mean, seed_efficiency_sd)) + 
  geom_point(aes(color = as.factor(seed_classification)), alpha = 0.5) + 
  scale_color_manual(values = color_map) + 
  facet_wrap(vars(seed_classification))

ggplot(df_tmp, aes(x = seed_classification, y = seed_efficiency_mean)) + 
  geom_boxplot() +
  scale_fill_manual(values = color_map)

ggplot(df_tmp, aes(x = seed_classification, y = seed_efficiency_mean, fill = seed_classification)) +
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=seed_classification), position = position_jitter(width = .15), size = .5, alpha = 0.5 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map) + 
    xlab('Classification') +
    ylab('Points per update (average)') +
    theme(legend.position = 'none') + 
    theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1))
ggsave(paste0(plot_dir, '/final_dom_efficiency.pdf'), width = 6, height = 5, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_efficiency.png'), width = 6, height = 5, units = 'in')

ggplot(df_tmp[df_tmp$seed_classification != seed_class_small,], aes(x = seed_classification, y = 1/seed_efficiency_mean, fill = seed_classification)) +
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=seed_classification), position = position_jitter(width = .15), size = .5, alpha = 0.5 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map) + 
    xlab('Classification') +
    ylab('Updates per point (average)') +
    theme(legend.position = 'none') + 
    theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1))
