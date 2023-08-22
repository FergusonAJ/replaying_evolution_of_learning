rm(list = ls())

library(ggplot2)

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'exploratory_replay_data_analyzed.csv')
df_exploratory = read.csv(base_data_filename)
df_exploratory = df_exploratory[df_exploratory$true_seed != 4219,]
  
df_max_gain_summary = df_exploratory[df_exploratory$is_learning & !is.na(df_exploratory$frac_diff),] %>% dplyr::group_by(true_seed) %>% dplyr::summarize(
  max_gain = max(frac_diff, na.rm = T)
)
df_max_gain_summary$label = paste0('Seed ', df_max_gain_summary$true_seed, '; max diff = ', df_max_gain_summary$max_gain)
df_exploratory$max_gain_label = NA
df_exploratory$is_max_gain = F
for(true_seed in unique(df_exploratory$true_seed)){
  df_exploratory[df_exploratory$true_seed == true_seed,]$max_gain_label = df_max_gain_summary[df_max_gain_summary$true_seed == true_seed,]$label
  max_gain = df_max_gain_summary[df_max_gain_summary$true_seed == true_seed,]$max_gain
  df_exploratory[df_exploratory$true_seed == true_seed & !is.na(df_exploratory$frac_diff) & df_exploratory$frac_diff == max_gain,]$is_max_gain = T
}

# Plot!
create_dir_if_needed(plot_dir)

img_width = 16
img_height = 9

ggp_exploratory = ggplot(df_exploratory[df_exploratory$is_learning & !is.na(df_exploratory$frac_diff),], aes(x = frac_diff)) + 
  geom_histogram(binwidth = 0.02, fill = '#aa3300', breaks = seq(-0.5, 1, 0.02)) +
  geom_histogram(data = df_max_gain_summary, mapping = aes(x = max_gain), binwidth = 0.02, fill = '#0033aa', alpha = 0.5, breaks = seq(-0.5, 1, 0.02))  +
  xlab('Difference in potentiation fraction') + 
  ylab('Count')


# Load data
base_data_filename = paste0(data_dir, 'targeted_replay_data_analyzed.csv')
df_targeted = read.csv(base_data_filename)
df_targeted[df_targeted$lineage_classification == 'Small',]$lineage_classification = seed_class_small
df_targeted[!is.na(df_targeted$prev_lineage_classification) & df_targeted$prev_lineage_classification == 'Small',]$prev_lineage_classification = seed_class_small
summary_filename = paste0(data_dir, 'targeted_replay_analysis_summary.csv')
df_targeted_summary = read.csv(summary_filename)

ggp_targeted = ggplot(df_targeted[df_targeted$is_learning & !is.na(df_targeted$target_window_potentiation_diff),], aes(x = target_window_potentiation_diff, fill = as.factor(is_largest_potentiation_gain))) + 
  geom_histogram(binwidth=0.02) + 
  xlab('Single-step difference in potentiation') + 
  ylab('Count') + 
  theme(legend.position = 'none')

df_exploratory_trimmed = df_exploratory[df_exploratory$is_learning & !is.na(df_exploratory$frac_diff), c('true_seed', 'frac_diff', 'is_max_gain')]
df_targeted_trimmed = df_targeted[df_targeted$is_learning & !is.na(df_targeted$target_window_potentiation_diff), c('true_seed', 'target_window_potentiation_diff', 'is_largest_potentiation_gain')]

colnames(df_exploratory_trimmed) = c('true_seed', 'diff', 'is_max')
colnames(df_targeted_trimmed) = c('true_seed', 'diff', 'is_max')

df_exploratory_trimmed$replay_level = 'Exploratory'
df_targeted_trimmed$replay_level = 'Targeted'

df_combined = rbind(df_exploratory_trimmed, df_targeted_trimmed)

ggplot(df_combined, aes(x = diff, fill = as.factor(is_max))) + 
  geom_histogram(binwidth=0.02) + 
  xlab('Single-step difference in potentiation') + 
  ylab('Count') + 
  facet_grid(rows = vars(replay_level))
  theme(legend.position = 'none')
