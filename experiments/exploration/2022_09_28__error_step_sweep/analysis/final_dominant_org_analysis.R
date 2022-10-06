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
date_map = c(
  '1_0' = '2022_09_28',
  '0_0-01' = '2022_09_28',
  '0_0-02' = '2022_09_28',
  '0_03' = '2022_10_04',
  '0_04' = '2022_10_04',
  '0_05' = '2022_10_04',
  '0_0-1' = '2022_10_05'
)

step_map = c(
  '1_0' = 0,
  '0_0-01' = 0.01,
  '0_0-02' = 0.02,
  '0_03' = 0.03,
  '0_04' = 0.04,
  '0_05' = 0.05,
  '0_0-1' = 0.1
)
base_map = c(
  '1_0' = 1,
  '0_0-01' = 0,
  '0_0-02' = 0,
  '0_03' = 0,
  '0_04' = 0,
  '0_05' = 0,
  '0_0-1' = 0
)

for(cue_str in c('2c', '3c1s')){
  if(cue_str == '2c'){
    source('../../../../global_shared_files/constant_vars__two_cues.R')
    source('../../../../global_shared_files/shared_funcs__two_cues.R')
  } else {
    source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
    source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')
  }
  for(error_step_str in c('1_0', '0_0-01', '0_0-02', '0_03', '0_04', '0_05')){
    date_str = date_map[error_step_str]
    filename = paste0('../../', date_str, '__', cue_str, '_error_step_', error_step_str, '/data/combined_final_dominant_data.csv')
    if(!file.exists(filename)){
      print(paste0('Cannot find file: ', filename))
      quit()
    }
    print(paste0('Processing: ', filename))
    error_base = base_map[error_step_str]
    error_step = step_map[error_step_str]
    df_tmp = read.csv(filename)
    df_tmp = classify_individual_trials(df_tmp)
    df_tmp = classify_seeds(df_tmp)
    df_tmp$cues = cue_str
    df_tmp$error_base = error_base
    df_tmp$error_step = error_step
    if(cue_str == '2c'){
      df_tmp$doors_correct_3 = NA
      df_tmp$doors_taken_3 = NA
      df_tmp$doors_incorrect_3 = NA
    }
    df_summary_tmp = summarize_final_dominant_org_data(df_tmp)
    df_summary_tmp$cues = cue_str
    df_summary_tmp$error_step = error_step
    df_summary_tmp$error_base = error_base
    classification_summary_tmp = summarize_classifications(df_summary_tmp)
    classification_summary_tmp$cues = cue_str
    classification_summary_tmp$error_step = error_step
    classification_summary_tmp$error_base = error_base
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
  facet_grid(rows = vars(cues), cols = vars(error_step)) +
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
  facet_grid(rows = vars(cues), cols = vars(error_step)) +
  theme(axis.text.x = element_blank())
ggsave(paste0(plot_dir, '/raincloud_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/raincloud_merit.png'), width = 9, height = 6, units = 'in')

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
  facet_grid(rows = vars(cues), cols = vars(error_step)) +
  theme(axis.text.x = element_blank())

ggplot(df[df$error_base == 1 && df$cues == '2c',], aes(x = correct_doors, y = incorrect_doors, color = seed_classification_factor)) +
  geom_point(alpha = 0.2) +
  scale_color_manual(values = color_map)


ggplot(df_summary[df_summary$error_base == 1 && df_summary$cues == '2c',], aes(x = correct_doors_mean, y = incorrect_doors_mean, color = seed_classification_factor)) +
  geom_point() +
  scale_color_manual(values = color_map)

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(error_step), y = merit, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Correct') + 
  theme(legend.position = 'bottom')

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(error_step), y = correct_doors, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Incorrect') + 
  theme(legend.position = 'bottom')
ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(error_step), y = incorrect_doors, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Incorrect') + 
  theme(legend.position = 'bottom')

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(error_step), y = incorrect_exits, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  xlab('Classification') + 
  ylab('Doors Incorrect') + 
  theme(legend.position = 'bottom')

ggplot(df_summary[df_summary$seed_classification == seed_class_error_correction,], aes(x = as.factor(error_step), y = genome_length, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom')

ggplot(df[df$seed_classification == seed_class_error_correction,], aes(x = as.factor(error_step), y = accuracy, fill = as.factor(cues))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(cues)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom')

df$tmp_score = 
  df$correct_doors * 1 + 
  df$correct_exits * 0 + 
  df$incorrect_doors * (0 + df$incorrect_doors * 0.01) + 
  df$incorrect_exits * -1

df$tmp_score_2 = 
  df$correct_doors * 1 + 
  df$correct_exits * 0 + 
  df$incorrect_doors * (0 + df$incorrect_doors * 0.02) + 
  df$incorrect_exits * -1


ggplot(df[df$seed_classification == seed_class_error_correction | df$seed_classification == seed_class_learning,], aes(x = merit, y = tmp_score, color = seed_classification_factor)) + 
  geom_point(alpha = 0.2) + 
  theme(legend.position = 'bottom') +
  scale_color_manual(values = color_map) + 
  facet_grid(rows = vars(cues), cols = vars(error_step))
  
ggplot(df_summary[df_summary$seed_classification %in% c(seed_class_learning, seed_class_error_correction),], aes(x = as.factor(error_step), y = merit_mean, fill = as.factor(seed_classification_factor))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(seed_classification_factor)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom') + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  facet_grid(rows = vars(cues))

ggplot(df[df$seed_classification %in% c(seed_class_learning, seed_class_error_correction),], aes(x = as.factor(error_step), y = tmp_score, fill = as.factor(seed_classification_factor))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(seed_classification_factor)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.2 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'bottom') + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  facet_grid(rows = vars(cues))

ggplot(df[df$cues == '3c1s',], aes(x = as.factor(error_step), y = merit)) + 
  geom_boxplot()

ggplot(df[df$cues == '3c1s',], aes(x = as.factor(error_step), y = correct_doors)) + 
  geom_boxplot()

ggplot(df[df$cues == '3c1s',], aes(x = as.factor(error_step), y = incorrect_doors)) + 
  geom_boxplot()

ggplot(df[df$cues == '3c1s',], aes(x = as.factor(error_step), y = accuracy)) + 
  geom_boxplot()

ggplot(df[df$cues == '2c' & df$seed_classification == seed_class_error_correction,], aes(x = correct_doors, y = incorrect_doors, color = as.factor(error_step))) + 
  geom_point(alpha=0.2)

df$merit_1_0 = df$correct_doors - df$incorrect_doors
df$merit_0_01 = df$correct_doors - (df$incorrect_doors * df$incorrect_doors * 0.01)
df$merit_0_02 = df$correct_doors - (df$incorrect_doors * df$incorrect_doors * 0.02)
df$penalty_0_01 = df$incorrect_doors * 0.01
df$penalty_0_02 = df$incorrect_doors * 0.02

ggplot(df[df$cues == '2c' & df$seed_classification == seed_class_error_correction,], aes(x = merit, y = merit_1_0, color = as.factor(error_step))) + 
  geom_point(alpha=0.1) + 
  geom_abline()
ggplot(df[df$cues == '2c' & df$seed_classification == seed_class_error_correction,], aes(x = merit, y = merit_0_01, color = as.factor(error_step))) + 
  geom_point(alpha=0.1) + 
  geom_abline()
ggplot(df[df$cues == '2c' & df$seed_classification == seed_class_error_correction,], aes(x = merit, y = merit_0_02, color = as.factor(error_step))) + 
  geom_point(alpha=0.1) + 
  geom_abline()

ggplot(df[df$cues == '2c' & df$seed_classification == seed_class_error_correction,], aes(x = merit, y = penalty_0_01, color = as.factor(error_step))) + 
  geom_point(alpha=0.1) + 
  geom_abline(slope=0.01)
ggplot(df[df$cues == '2c' & df$seed_classification == seed_class_error_correction,], aes(x = merit, y = penalty_0_02, color = as.factor(error_step))) + 
  geom_point(alpha=0.1) + 
  geom_abline(slope=0.02)


ggplot(df_summary[df_summary$cues == '3c1s' & df_summary$seed_classification == seed_class_error_correction,], aes(x = correct_doors_mean, y = incorrect_doors_mean, color = as.factor(error_step))) + 
  geom_point(alpha=0.5)


ggplot(df_summary[df_summary$cues == '3c1s',], aes(x = as.factor(error_step), y = correct_doors_mean)) + 
  geom_boxplot()
ggplot(df_summary[df_summary$cues == '3c1s',], aes(x = as.factor(error_step), y = incorrect_doors_mean)) + 
  geom_boxplot()


# Raincloud plot of merit
ggplot(df, aes(x = as.factor(error_step), y = merit, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(cues), cols = vars(seed_classification_factor))


ggplot(df_summary, aes(x = as.factor(error_step), y = merit_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(cues), cols = vars(seed_classification_factor)) +
  theme(axis.text.x = element_blank())

ggplot(df_summary, aes(x = as.factor(error_step), y = incorrect_exits_mean, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(cues), cols = vars(seed_classification_factor)) +
  theme(axis.text.x = element_blank())

df$c = (df$correct_doors - 70) / (df$incorrect_doors * df$incorrect_doors)

ggplot(df[df$seed_classification == 'Error correction' & df$c < 1 & df$c > 0,], aes(x = as.factor(error_step), y = c, fill = seed_classification_factor)) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=seed_classification_factor), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'bottom') + 
  facet_grid(rows = vars(cues), cols = vars(seed_classification_factor)) +
  theme(axis.text.x = element_blank())
