rm(list = ls())

library(ggplot2)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'targeted_replay_data_analyzed.csv')
df = read.csv(base_data_filename)
df[df$lineage_classification == 'Small',]$lineage_classification = seed_class_small
df[!is.na(df$prev_lineage_classification) & df$prev_lineage_classification == 'Small',]$prev_lineage_classification = seed_class_small
summary_filename = paste0(data_dir, 'targeted_replay_analysis_summary.csv')
df_summary = read.csv(summary_filename)

# Plot!
if(plot_dir == '../plots/'){
  plot_dir = paste0(plot_dir, 'targeted_replays/')
}
create_dir_if_needed(plot_dir)

img_width = 16
img_height = 9

##################### FRACTIONS OVER TIME #########################
if(T){
  # Learning frac over time
  ggplot(df[df$is_learning == T,], aes(x=target_window_depth, group = as.factor(true_seed))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 1.25) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification')
  ggsave(paste0(plot_dir, '/learning_frac_over_time.pdf'), width = img_width,  height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time.png'), width = img_width,  height = img_height, units = 'in')
  
  # Learning frac over time - faceted 
  ggplot(df[df$is_learning == T,], aes(x=target_window_depth, group = as.factor(true_seed))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 1.25) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed)) 
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet.png'), width = img_width, height = img_height, units = 'in')
  
  # Frac over time for EVERY behavior
  ggplot(df, aes(x=target_window_depth, group = as.factor(seed_classification_factor))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(seed_classification_factor)), size = 1.25) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed)) 
  ggsave(paste0(plot_dir, '/all_frac_over_time_facet.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/all_frac_over_time_facet.png'), width = img_width, height = img_height, units = 'in')
  
  # Area plots
  ggplot(df, aes(x=target_window_depth, group = as.factor(seed_classification_factor))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_area(mapping=aes(y = frac, fill = as.factor(seed_classification_factor)), size = 1.25) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed)) 
  ggsave(paste0(plot_dir, '/areas_over_time_facet.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/areas_over_time_facet.png'), width = img_width, height = img_height, units = 'in')
  
  # Find different orderings
  df_summary$max_diff_order = order(df_summary$max_potentiation_diff)
  df_summary$min_diff_order = order(df_summary$min_potentiation_diff)
  df_summary$max_label = paste0('Seed ', df_summary$true_seed, '; max diff = ', df_summary$max_potentiation_diff)
  df_summary$min_label = paste0('Seed ', df_summary$true_seed, '; min diff = ', df_summary$min_potentiation_diff)
  df$max_label = NA
  df$min_label = NA
  for(true_seed in unique(df$true_seed)){
    df[df$true_seed == true_seed,]$max_label = df_summary[df_summary$true_seed == true_seed,]$max_label
    df[df$true_seed == true_seed,]$min_label = df_summary[df_summary$true_seed == true_seed,]$min_label
  }
  df$true_seed_factor_max = factor(df$max_label, levels = df_summary[df_summary$max_diff_order,]$max_label)
  df$true_seed_factor_min = factor(df$min_label, levels = df_summary[df_summary$min_diff_order,]$min_label)
  
  # Learning fracs ordered from smallest to largest single-step potentiation gain
  ggplot(df[df$is_learning == T,], aes(x=target_window_depth, group = as.factor(true_seed))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 1.25) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed_factor_max)) 
  ggsave(paste0(plot_dir, '/learning_frac_over_time_ordered_facet.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_ordered_facet.png'), width = img_width, height = img_height, units = 'in')
  
  # Six reps with the smallest maximal jumps
  bottom_true_seeds = df_summary[df_summary$max_diff_order,]$true_seed[1:5]
  ggplot(df[df$is_learning == T & df$true_seed %in% bottom_true_seeds,], aes(x=target_window_depth, group = as.factor(true_seed))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed_factor_max)) 
  ggsave(paste0(plot_dir, '/learning_frac_over_time_smallest_jumps.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_smallest_jumps.png'), width = img_width, height = img_height, units = 'in')
  
  # Six reps with the largest maximal jumps
  top_true_seeds = df_summary[df_summary$max_diff_order,]$true_seed[(nrow(df_summary) - 5) : nrow(df_summary)]
  ggplot(df[df$is_learning == T & df$true_seed %in% top_true_seeds,], aes(x=target_window_depth, group = as.factor(true_seed))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed_factor_max)) 
  ggsave(paste0(plot_dir, '/learning_frac_over_time_largest_jumps.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_largest_jumps.png'), width = img_width, height = img_height, units = 'in')
  
  # Learning fracs ordered from smallest to largest single-step potentiation LOSS
  ggplot(df[df$is_learning == T,], aes(x=target_window_depth, group = as.factor(true_seed))) + 
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
    geom_line(mapping=aes(y = frac), size = 1.05) + 
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 1.25) + 
    scale_color_manual(values = color_map) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') + 
    theme(legend.position = 'bottom') + 
    labs(color = 'Classification') +
    labs(fill = 'Classification') + 
    facet_wrap(vars(true_seed_factor_min)) 
  ggsave(paste0(plot_dir, '/learning_frac_over_time_ordered_min_facet.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_ordered_min_facet.png'), width = img_width, height = img_height, units = 'in')
}

##################### DISTRIBUTIONS OF POTENTIATION CHANGES #########################
if(T){
  # Histogram of ALL learning potentiation changes
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff),], aes(x = target_window_potentiation_diff, fill = as.factor(is_largest_potentiation_gain))) + 
    geom_histogram(binwidth=0.02) + 
    xlab('Single-step difference in potentiation') + 
    ylab('Count') + 
    theme(legend.position = 'none')
  ggsave(paste0(plot_dir, '/all_potentiation_differences.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/all_potentiation_differences.png'), width = img_width, height = img_height, units = 'in')
  
  # Histogram of LARGEST learning potentiation changes
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff) & df$is_largest_potentiation_gain,], aes(x = target_window_potentiation_diff)) + 
    geom_histogram(binwidth=0.04) + 
    xlab('Single-step difference in potentiation') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/largest_potentiation_differences.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/largest_potentiation_differences.png'), width = img_width, height = img_height, units = 'in')

  # Histogram of SMALLEST learning potentiation changes
  ggplot(df_summary, aes(x = min_potentiation_diff)) + 
    geom_histogram(binwidth = 0.04) +
    xlab('Single-step difference in potentiation') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/smallest_potentiation_differences.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/smallest_potentiation_differences.png'), width = img_width, height = img_height, units = 'in')
}

##################### DISTRIBUTIONS BY AFTER BEHAVIOR #########################
if(T){
  # All steps
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff),], 
         aes(x = lineage_classification, y = target_window_potentiation_diff, fill = lineage_classification)) + 
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=lineage_classification), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/behavior_all_potentiation_difference_rainclouds.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/behavior_all_potentiation_difference_rainclouds.png'), width = img_width, height = img_height, units = 'in')
  
  # Largest steps
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff) & df$is_largest_potentiation_gain,], 
         aes(x = lineage_classification, y = target_window_potentiation_diff, fill = lineage_classification)) + 
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=lineage_classification), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/behavior_largest_potentiation_difference_rainclouds.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/behavior_largest_potentiation_difference_rainclouds.png'), width = img_width, height = img_height, units = 'in')

  # Counts of behavior classification
  df_behavior_summary = df[df$is_learning & df$is_largest_potentiation_gain,] %>% 
    dplyr::group_by(lineage_classification) %>% 
    dplyr::summarize(
      count = dplyr::n()
    )
  ggplot(df_behavior_summary, aes(x = lineage_classification, y = count, fill = lineage_classification)) + 
    geom_col() + 
    geom_text(aes(x = lineage_classification, y = count + 1, label = count)) + 
    scale_fill_manual(values = color_map) +
    theme(legend.position = 'none') + 
    xlab('Behavior of largest potentiating mutation') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/largest_potentiating_mutation_behavior_classification_counts.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/largest_potentiating_mutation_behavior_classification_counts.png'), width = img_width, height = img_height, units = 'in')
}

##################### DISTRIBUTIONS BY BEFORE BEHAVIOR #########################
if(T){
  # All steps
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff),], 
         aes(x = prev_lineage_classification, y = target_window_potentiation_diff, fill = prev_lineage_classification)) + 
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=prev_lineage_classification), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/prev_behavior_all_potentiation_difference_rainclouds.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/prev_behavior_all_potentiation_difference_rainclouds.png'), width = img_width, height = img_height, units = 'in')
  
  # Largest steps
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff) & df$is_largest_potentiation_gain,], 
         aes(x = prev_lineage_classification, y = target_window_potentiation_diff, fill = prev_lineage_classification)) + 
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=prev_lineage_classification), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = color_map) +
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/prev_behavior_largest_potentiation_difference_rainclouds.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/prev_behavior_largest_potentiation_difference_rainclouds.png'), width = img_width, height = img_height, units = 'in')

  # Counts of behavior classification
  df_prev_behavior_summary = df[df$is_learning & df$is_largest_potentiation_gain,] %>% 
    dplyr::group_by(prev_lineage_classification) %>% 
    dplyr::summarize(
      count = dplyr::n()
    )
  ggplot(df_prev_behavior_summary, aes(x = prev_lineage_classification, y = count, fill = prev_lineage_classification)) + 
    geom_col() + 
    geom_text(aes(x = prev_lineage_classification, y = count + 1, label = count)) + 
    scale_fill_manual(values = color_map) +
    theme(legend.position = 'none') + 
    xlab('Behavior of largest potentiating mutation') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/largest_potentiating_mutation_prev_behavior_classification_counts.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/largest_potentiating_mutation_prev_behavior_classification_counts.png'), width = img_width, height = img_height, units = 'in')
}
  
##################### DISTRIBUTIONS BY FITNESS EFFECT #########################
if(T){
  df$fitness_classification = 'Neutral'
  df[!is.na(df$lineage_merit_mean_frac) & df$lineage_merit_mean_frac > 6,]$fitness_classification = 'Slightly beneficial'
  df[!is.na(df$lineage_merit_mean_frac) & df$lineage_merit_mean_frac > 12,]$fitness_classification = 'Beneficial'
  df[!is.na(df$lineage_merit_mean_frac) & df$lineage_merit_mean_frac < (2^-6),]$fitness_classification = 'Slightly deleterious'
  df[!is.na(df$lineage_merit_mean_frac) & df$lineage_merit_mean_frac < (2^-12),]$fitness_classification = 'Deleterious'
  
  df$fitness_classification_factor = factor(df$fitness_classification, levels = c('Deleterious', 'Slightly deleterious', 'Neutral', 'Slightly beneficial', 'Beneficial'))
  #fitness_color_map = c(
  #  'Deleterious' = '#cc3311',
  #  'Neutral' = '#ee7733',
  #  'Beneficial' = '#009988'
  #)
  fitness_color_map = c( 
   'Deleterious' = '#a6611a',
   'Slightly deleterious' = '#dfc27d',
   'Neutral' = '#5f5f5f', #f5f5f5',
   'Slightly beneficial' = '#80cdc1',
   'Beneficial' = '#018571'
  )
  # Counts of fitness classification
  df_fitness_effect_summary = df[df$is_learning & df$is_largest_potentiation_gain,] %>% 
    dplyr::group_by(fitness_classification, fitness_classification_factor) %>% 
    dplyr::summarize(
      count = dplyr::n()
    )
  # Counts for LARGEST potentiating mutations
  ggplot(df_fitness_effect_summary, aes(x = fitness_classification_factor, y = count, fill = fitness_classification_factor)) + 
    geom_col() + 
    geom_text(aes(x = fitness_classification_factor, y = count + 1, label = count)) + 
    scale_fill_manual(values = fitness_color_map) +
    theme(legend.position = 'none') + 
    xlab('Fitness effect of largest potentiating mutation') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_largest_step_counts.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_largest_step_counts.png'), width = img_width, height = img_height, units = 'in')
  
  # Raincloud of potentiation steps per fitness effect for LARGEST mutations
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff) & df$is_largest_potentiation_gain,], 
         aes(x = fitness_classification_factor, y = target_window_potentiation_diff, fill = fitness_classification_factor)) + 
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=fitness_classification_factor), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = fitness_color_map) +
    scale_color_manual(values = fitness_color_map) + 
    xlab('Fitness classification of largest potentiating mutation') + 
    ylab('Potentiation difference of leargest potentiating mutation') + 
    theme(legend.position = 'none')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_largest_step_rainclouds.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_largest_step_rainclouds.png'), width = img_width, height = img_height, units = 'in')
  
  # Counts of fitness classification
  df_fitness_effect_all_summary = df[df$is_learning,] %>% 
    dplyr::group_by(fitness_classification, fitness_classification_factor) %>% 
    dplyr::summarize(
      count = dplyr::n()
    )
  
  # Counts for ALL potentiating mutations
  ggplot(df_fitness_effect_all_summary, aes(x = fitness_classification_factor, y = count, fill = fitness_classification_factor)) + 
    geom_col() + 
    geom_text(aes(x = fitness_classification_factor, y = count + 50, label = count)) + 
    scale_fill_manual(values = fitness_color_map) +
    theme(legend.position = 'none') + 
    xlab('Fitness effect of mutation') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_all_counts.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_all_counts.png'), width = img_width, height = img_height, units = 'in')
  
  # Raincloud of potentiation steps per fitness effect for ALL mutations
  ggplot(df[df$is_learning & !is.na(df$target_window_potentiation_diff),], 
         aes(x = fitness_classification_factor, y = target_window_potentiation_diff, fill = fitness_classification_factor)) + 
    geom_flat_violin( position = position_nudge(x = .2, y = 0), alpha = .8 ) +
    geom_point( mapping=aes(color=fitness_classification_factor), position = position_jitter(width = .15), size = .5, alpha = 0.8 ) +
    geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) + 
    scale_fill_manual(values = fitness_color_map) +
    scale_color_manual(values = fitness_color_map) + 
    xlab('Fitness effect') + 
    ylab('Potentiation difference') + 
    theme(legend.position = 'none')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_all_rainclouds.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/fitness_effect_classification_all_rainclouds.png'), width = img_width, height = img_height, units = 'in')
}
  
##################### DEPTH RELATIVE TO LEARNING #########################
if(T){
  ggplot(df[df$is_largest_potentiation_gain,], aes(x = relative_depth)) + 
    geom_histogram(binwidth = 100) + 
    xlab('Depth of largest potentiation step relative to the first appearance of learning') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/relative_depth_to_learning.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/relative_depth_to_learning.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df[df$is_largest_potentiation_gain,], aes(x = depth_frac)) + 
    geom_histogram(binwidth = 0.01) +
    xlab('Depth of largest potentiation step as a fraction of the first appearance of learning ') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/frac_depth_to_learning.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/frac_depth_to_learning.png'), width = img_width, height = img_height, units = 'in')
}


ggplot(df[df$is_learning & !is.na(df$lineage_merit_mean_frac),], aes(x = lineage_merit_mean_frac)) + 
  geom_histogram(bins=600) + 
  scale_x_log10()

inner_exp = 5
inner_mask = df$is_learning & !is.na(df$lineage_merit_mean_frac) & df$lineage_merit_mean_frac > 2^(-1 * inner_exp) & df$lineage_merit_mean_frac < 2^inner_exp
cat('Frac covered by inner_mask:', sum(inner_mask) / sum(df$is_learning & !is.na(df$lineage_merit_mean_frac)), '\n')

ggplot(df[inner_mask,], aes(x = lineage_merit_mean_frac)) + 
  geom_histogram() + 
  scale_x_log10()
  
ggplot(df[!is.na(df$lineage_merit_mean_frac),], aes(x = lineage_merit_mean_frac)) + 
  geom_histogram() + 
  scale_x_log10()

ggplot(df[!is.na(df$lineage_merit_mean_frac) & df$fitness_classification == 'Neutral',], aes(x = lineage_merit_mean_frac)) + 
  geom_histogram() + 
  scale_x_log10()

ggplot(df[!is.na(df$lineage_merit_mean_frac) & df$fitness_classification == 'Beneficial',], aes(x = lineage_merit_mean_frac)) + 
  geom_histogram() + 
  scale_x_log10()

ggplot(df[!is.na(df$lineage_merit_mean_frac) & df$fitness_classification == 'Deleterious',], aes(x = lineage_merit_mean_frac)) + 
  geom_histogram() + 
  scale_x_log10()

df$lineage_merit_mean_frac_scaled = log(df$lineage_merit_mean_frac, 2)
ggplot(df[!is.na(df$lineage_merit_mean_frac) & df$is_largest_potentiation_gain,], aes(x = lineage_merit_mean_frac_scaled, y = target_window_potentiation_diff)) + 
  geom_point()
