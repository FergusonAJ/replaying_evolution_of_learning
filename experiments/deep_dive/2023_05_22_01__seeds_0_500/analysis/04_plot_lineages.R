rm(list = ls())

library(ggplot2)

# Local include
source('./local_setup.R')

# Load data
df_summary = load_processed_summary_after_lineage_analysis()
seeds_to_process = get_seeds_to_process()

for(seed in seeds_to_process){
  df_lineage = load_processed_lineage(seed)
  print(paste0('Plotting seed: ', seed))
  plot_dir = paste0('../plots/reps/', seed, '/lineage')
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  
  ggplot(df_lineage, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = accuracy_mean)) +
    geom_point(aes(y = accuracy_min), alpha = 0.1) +
    geom_point(aes(y = accuracy_max), alpha = 0.1) + 
    scale_color_manual(values = color_map) +
    ylab('Accuracy (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/accuracy.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/accuracy.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df_lineage, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = correct_doors_mean)) +
    geom_point(aes(y = correct_doors_min), alpha = 0.1) +
    geom_point(aes(y = correct_doors_max), alpha = 0.1) + 
    scale_color_manual(values = color_map) +
    ylab('Correct doors (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/correct_doors.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/correct_doors.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_lineage, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = incorrect_doors_mean)) +
    geom_point(aes(y = incorrect_doors_min), alpha = 0.1) +
    geom_point(aes(y = incorrect_doors_max), alpha = 0.1) + 
    scale_color_manual(values = color_map) +
    ylab('Incorrect doors (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/incorrect_doors.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/incorrect_doors.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_lineage, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = merit_mean)) +
    geom_point(aes(y = merit_min), alpha = 0.1) +
    geom_point(aes(y = merit_max), alpha = 0.1) +
    scale_color_manual(values = color_map) + 
    scale_y_continuous(trans = 'log2') +
    ylab('Merit (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/merit.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/merit.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df_lineage, aes(x = depth)) +
    geom_line(aes(y = merit_mean)) + 
    geom_point(aes(y = merit_mean, color = seed_classification), size = 0.25) + 
    scale_y_continuous(trans = 'log2') +
    scale_color_manual(values = color_map) +
    ylab('Mean merit') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/merit_line_with_points.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/merit_line_with_points.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df_lineage, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = genome_length)) +
    scale_color_manual(values = color_map) +
    ylab('Genome length') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/genome_length.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/genome_length.png'), width = 8, height = 6, units = 'in')
  
}
 
  ## Plot focal window, if applicable 
  #focal_start = focal_start_map[as.character(seed)]
  #focal_stop = focal_stop_map[as.character(seed)]
  #focal_mut = focal_mut_map[as.character(seed)]
  #if(!is.na(focal_start) & !is.na(focal_stop) & !is.na(focal_mut)){
  #  mask_focal = df$depth >= focal_start & df$depth <= focal_stop
  #  
  #  focal_mut_accuracy = df[df$depth == focal_mut,]$accuracy_mean
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
  #    geom_hline(aes(yintercept = focal_mut_accuracy), linetype = 'dashed', alpha = 0.5) +
  #    geom_point(aes(y = accuracy_mean, color = seed_classification)) +
  #    geom_line(aes(y = accuracy_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Mean accuracy') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/accuracy__focal.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/accuracy__focal.png'), width = 8, height = 6, units = 'in')
  #    
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_point(aes(y = merit_mean, color = seed_classification)) +
  #    geom_line(aes(y = merit_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/merit__focal.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit__focal.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_point(aes(y = merit_mean, color = seed_classification)) +
  #    geom_line(aes(y = merit_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)') +
  #    scale_y_continuous(trans = 'log2')
  #  ggsave(paste0(plot_dir, '/merit_log2__focal.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit_log2__focal.png'), width = 8, height = 6, units = 'in')
  #  
  #  focal_mut_merit = df[df$depth == focal_mut,]$merit_mean
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
  #    geom_hline(aes(yintercept = focal_mut_merit), linetype = 'dashed', alpha = 0.5) +
  #    geom_point(aes(y = merit_mean, color = seed_classification)) +
  #    geom_line(aes(y = merit_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/merit__focal_cross.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit__focal_cross.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
  #    geom_hline(aes(yintercept = focal_mut_merit), linetype = 'dashed', alpha = 0.5) +
  #    geom_point(aes(y = merit_mean, color = seed_classification)) +
  #    geom_line(aes(y = merit_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)') +
  #    scale_y_continuous(trans = 'log2')
  #  ggsave(paste0(plot_dir, '/merit_log2__focal_cross.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit_log2__focal_cross.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
  #    geom_hline(aes(yintercept = 1), linetype = 'dashed', alpha = 0.5) +
  #    geom_point(aes(y = merit_mean/focal_mut_merit, color = seed_classification)) +
  #    geom_line(aes(y = merit_mean/focal_mut_merit)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Relative mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/merit__focal_cross_relative.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit__focal_cross_relative.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
  #    geom_hline(aes(yintercept = 1), linetype = 'dashed', alpha = 0.5) +
  #    geom_point(aes(y = log(merit_mean,1.1)/log(focal_mut_merit,1.1), color = seed_classification)) +
  #    geom_line(aes(y = log(merit_mean,1.1)/log(focal_mut_merit,1.1))) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Relative mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/merit_log__focal_cross_relative.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit_log__focal_cross_relative.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df, aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
  #    geom_hline(aes(yintercept = focal_mut_merit), linetype = 'dashed', alpha = 0.5) +
  #    geom_point(aes(y = merit_mean, color = seed_classification)) +
  #    geom_line(aes(y = merit_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Mean merit') + 
  #    xlab('Phylogenetic depth (from ancestor)') +
  #    scale_y_continuous(trans = 'log2')
  #  ggsave(paste0(plot_dir, '/merit_log2__cross.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/merit_log2__cross.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df[df$depth >= focal_start & df$depth <= focal_stop,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_point(aes(y = correct_doors_mean, color = seed_classification)) +
  #    geom_line(aes(y = correct_doors_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Correct doors') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/correct_doors__focal.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/correct_doors__focal.png'), width = 8, height = 6, units = 'in')
  #  
  #  ggplot(df[df$depth >= focal_start & df$depth <= focal_stop,], aes(x = depth)) +#, color = seed_classification)) + 
  #    geom_point(aes(y = incorrect_doors_mean, color = seed_classification)) +
  #    geom_line(aes(y = incorrect_doors_mean)) +
  #    scale_color_manual(values = color_map) +
  #    ylab('Incorrect doors') + 
  #    xlab('Phylogenetic depth (from ancestor)')
  #  ggsave(paste0(plot_dir, '/incorrect_doors__focal.pdf'), width = 8, height = 6, units = 'in')
  #  ggsave(paste0(plot_dir, '/incorrect_doors__focal.png'), width = 8, height = 6, units = 'in')
  #}