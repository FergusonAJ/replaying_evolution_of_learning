rm(list = ls())

library(ggplot2)

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'exploratory_replay_data_analyzed.csv')
df = read.csv(base_data_filename)
df = df[df$true_seed != 4219,]

# Plot!
if(plot_dir == '../plots/'){
  plot_dir = paste0(plot_dir, 'exploratory_replays/')
}
create_dir_if_needed(plot_dir)

img_width = 16
img_height = 9

##################### LEARNING FRAC OVER TIME #########################
if(T){
  # Learning frac over time
  ggplot(df[df$is_learning == T & df$is_necessary_exploratory_replay,], aes(x=relative_depth, group = as.factor(true_seed))) +
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
    labs(fill = 'Classification')
  ggsave(paste0(plot_dir, '/learning_frac_over_time.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time.png'), width = img_width, height = img_height, units = 'in')
  
  # Learning frac over time - faceted
  ggplot(df[df$is_learning == T & df$is_necessary_exploratory_replay,], aes(x=relative_depth, group = as.factor(true_seed))) +
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) +
    geom_line(mapping=aes(y = frac), size = 1.05) +
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) +
    scale_color_manual(values = color_map) +
    scale_fill_manual(values = color_map) +
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') +
    labs(color = 'Classification') +
    labs(fill = 'Classification') +
    theme(legend.position = 'bottom') + 
    facet_wrap(vars(true_seed))
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet.png'), width = img_width, height = img_height, units = 'in')
  
  # Learning frac over time
  ggplot(df[df$is_learning == T & df$is_necessary_exploratory_replay,], aes(x=depth_frac, group = as.factor(true_seed))) +
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) +
    geom_line(mapping=aes(y = frac), size = 1.05) +
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) +
    scale_color_manual(values = color_map) +
    scale_fill_manual(values = color_map) +
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Fraction of depth to learning') +
    ylab('Fraction of replicates that evolved learning') +
    labs(color = 'Classification') +
    theme(legend.position = 'bottom') + 
    labs(fill = 'Classification')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_norm_x.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_norm_x.png'), width = img_width, height = img_height, units = 'in')
  
  # Learning frac over time - faceted and normalized
  ggplot(df[df$is_learning == T & df$is_necessary_exploratory_replay,], aes(x=depth_frac, group = as.factor(true_seed))) +
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) +
    geom_line(mapping=aes(y = frac), size = 1.05) +
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) +
    scale_color_manual(values = color_map) +
    scale_fill_manual(values = color_map) +
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Fraction of depth to learning') +
    ylab('Fraction of replicates that evolved learning') +
    labs(color = 'Classification') +
    labs(fill = 'Classification') +
    theme(legend.position = 'bottom') + 
    facet_wrap(vars(true_seed))
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet_norm_x.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet_norm_x.png'), width = img_width, height = img_height, units = 'in')
  
  df_max_gain_summary = df[df$is_learning & !is.na(df$frac_diff),] %>% dplyr::group_by(true_seed) %>% dplyr::summarize(
    max_gain = max(frac_diff, na.rm = T)
  )
  df_max_gain_summary$label = paste0('Seed ', df_max_gain_summary$true_seed, '; max diff = ', df_max_gain_summary$max_gain)
  df$max_gain_label = NA
  for(true_seed in unique(df$true_seed)){
    df[df$true_seed == true_seed,]$max_gain_label = df_max_gain_summary[df_max_gain_summary$true_seed == true_seed,]$label
  }
   
  df$max_gain_order_true_seed_factor = factor(df$max_gain_label, levels = df_max_gain_summary[order(df_max_gain_summary$max_gain),]$label)
  # Learning frac over time - faceted and ordered by largest jump
  ggplot(df[df$is_learning == T & df$is_necessary_exploratory_replay,], aes(x=relative_depth, group = as.factor(true_seed))) +
    geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) +
    geom_line(mapping=aes(y = frac), size = 1.05) +
    geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) +
    scale_color_manual(values = color_map) +
    scale_fill_manual(values = color_map) +
    scale_y_continuous(limits = c(-0.1,1)) +
    xlab('Relative depth') +
    ylab('Fraction of replicates that evolved learning') +
    labs(color = 'Classification') +
    labs(fill = 'Classification') +
    theme(legend.position = 'bottom') + 
    facet_wrap(vars(max_gain_order_true_seed_factor))
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet_ordered.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/learning_frac_over_time_facet_ordered.png'), width = img_width, height = img_height, units = 'in')
  
}

##################### WINDOWS OF GAIN AND LOSS ########################
if(T){
  # Windows of potentiation gain and loss
  df_learning_grouped = dplyr::group_by(df[df$is_learning,], true_seed)
  df_learning_window_summary = dplyr::summarize(df_learning_grouped,
                                                count_total = dplyr::n(),
                                                count_needed = sum(is_necessary_exploratory_replay),
                                                count_gain_windows = sum(is_gain_window),
                                                count_loss_windows = sum(is_loss_window),
                                                count_needed_gain_windows = sum(is_gain_window & is_necessary_exploratory_replay),
                                                count_needed_loss_windows = sum(is_loss_window & is_necessary_exploratory_replay))
  
  ggplot(df_learning_window_summary, aes(x = count_needed)) +
    geom_bar() +
    scale_x_continuous(breaks = seq(0, 45, 5)) +
    xlab('Windows needed to reach 20% potentiation') +
    ylab('Count')
  ggsave(paste0(plot_dir, '/windows_needed.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/windows_needed.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_learning_window_summary, aes(x = count_needed_gain_windows)) +
    geom_bar() +
    scale_x_continuous(breaks = 1:10) +
    xlab('Number of gain windows') +
    ylab('Count')
  ggsave(paste0(plot_dir, '/gain_windows.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/gain_windows.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_learning_window_summary, aes(x = count_needed_gain_windows / count_needed)) +
    geom_histogram(breaks = seq(0, 1, 0.1)) +
    xlab('Fraction of windows that are gain windows') +
    ylab('Count')
  ggsave(paste0(plot_dir, '/gain_windows_frac.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/gain_windows_frac.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_learning_window_summary, aes(x = count_needed, y = count_needed_gain_windows)) +
    geom_abline(intercept = 0, slope = 1, linetype = 'dashed', alpha = 0.5) +
    geom_point(alpha = 0.25) +
    scale_x_continuous(limits = c(0,50)) +
    scale_y_continuous(limits = c(0,30)) +
    xlab('Number of windows needed') +
    ylab('Number of gain windows')
  ggsave(paste0(plot_dir, '/gain_windows_correlation.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/gain_windows_correlation.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_learning_window_summary, aes(x = count_needed_loss_windows)) +
    geom_bar() +
    scale_x_continuous(breaks = 0:8) +
    xlab('Number of loss windows') +
    ylab('Count')
  ggsave(paste0(plot_dir, '/loss_windows.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/loss_windows.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_learning_window_summary, aes(x = count_needed_loss_windows / count_needed)) +
    geom_histogram(breaks = seq(0, 1, 0.1)) +
    xlab('Fraction of windows that are loss windows') +
    ylab('Count')
  ggsave(paste0(plot_dir, '/loss_windows_frac.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/loss_windows_frac.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_learning_window_summary, aes(x = count_needed, y = count_needed_loss_windows)) +
    geom_abline(intercept = 0, slope = 1, linetype = 'dashed', alpha = 0.5) +
    geom_point(alpha = 0.25) +
    scale_x_continuous(limits = c(0,50)) +
    scale_y_continuous(limits = c(0,30)) +
    xlab('Number of windows needed') +
    ylab('Number of loss windows')
  ggsave(paste0(plot_dir, '/loss_windows_correlation.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/loss_windows_correlation.png'), width = img_width, height = img_height, units = 'in')
}  

##################### HISTOGRAMS OF POTENTIATION CHANGES ########################
if(T){ 
  ggplot(df[df$is_learning & !is.na(df$frac_diff),], aes(x = frac_diff)) + 
    geom_histogram(binwidth = 0.02, fill = '#aa3300', breaks = seq(-0.5, 1, 0.02)) + 
    xlab('Difference in potentiation fraction') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/potentiation_diff_histogram.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/potentiation_diff_histogram.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df[df$is_learning & !is.na(df$frac_diff),], aes(x = frac_diff)) + 
    geom_histogram(binwidth = 0.02, fill = '#aa3300', breaks = seq(-0.5, 1, 0.02)) +
    geom_histogram(data = df_max_gain_summary, mapping = aes(x = max_gain), binwidth = 0.02, fill = '#0033aa', alpha = 0.5, breaks = seq(-0.5, 1, 0.02))  +
    xlab('Difference in potentiation fraction') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/potentiation_diff_max_overlay_histogram.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/potentiation_diff_max_overlay_histogram.png'), width = img_width, height = img_height, units = 'in')
  
  ggplot(df_max_gain_summary, aes(x = max_gain)) + 
    geom_bar(fill = '#553255') + 
    xlab('Difference in potentiation fraction') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/potentiation_max_diff_histogram.pdf'), width = img_width, height = img_height, units = 'in')
  ggsave(paste0(plot_dir, '/potentiation_max_diff_histogram.png'), width = img_width, height = img_height, units = 'in')
    
}
