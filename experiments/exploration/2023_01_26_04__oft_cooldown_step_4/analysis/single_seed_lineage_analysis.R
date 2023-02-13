rm(list = ls())

library(ggplot2)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')

# Make sure plot/reps exists
if(!dir.exists('../plots/reps')){
  dir.create('../plots/reps')
}



for(seed in c(1:200)){#18,28,130)){ #1:200){
  input_filename = paste0('../data/reps/', seed, '/dominant_lineage_summary.csv') 
  if(!file.exists(input_filename)){
    print(paste0('File does not exist: ', input_filename))
    next
  }
  df = read.csv(input_filename)
  if(nrow(df) <= 1){
    print(paste0('File is empty or corrupted: ', input_filename))
    next
  }
  raw_filename =  paste0('../data/reps/', seed, '/dominant_lineage.csv') 
  if(!file.exists(raw_filename)){
    print(paste0('File does not exist: ', raw_filename))
    next
  }
  df_raw = read.csv(raw_filename)
  if(nrow(df_raw) <= 1){
    print(paste0('File is empty or corrupted: ', raw_filename))
    next
  }
  print(paste0('Plotting seed: ', seed))
  plot_dir = paste0('../plots/reps/', seed)
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = accuracy_mean)) +
    geom_point(aes(y = accuracy_min), alpha = 0.1) +
    geom_point(aes(y = accuracy_max), alpha = 0.1) + 
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/accuracy.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/accuracy.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = correct_doors_mean)) +
    geom_point(aes(y = correct_doors_min), alpha = 0.1) +
    geom_point(aes(y = correct_doors_max), alpha = 0.1) + 
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/correct_doors.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/correct_doors.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = incorrect_doors_mean)) +
    geom_point(aes(y = incorrect_doors_min), alpha = 0.1) +
    geom_point(aes(y = incorrect_doors_max), alpha = 0.1) + 
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/incorrect_doors.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/incorrect_doors.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = merit_mean)) +
    geom_point(aes(y = merit_min), alpha = 0.1) +
    geom_point(aes(y = merit_max), alpha = 0.1) +
    scale_color_manual(values = color_map) + 
    scale_y_continuous(trans = 'log2')
  ggsave(paste0(plot_dir, '/merit.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/merit.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = genome_length)) +
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/genome_length.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/genome_length.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df[df$depth >= 375 & df$depth <= 413,], aes(x = depth)) +#, color = seed_classification)) + 
    geom_vline(aes(xintercept=392), alpha = 0.2) +
    geom_hline(aes(yintercept=df[df$depth == 392,]$merit_mean), alpha = 0.2) +
    geom_point(aes(y = merit_mean, color = seed_classification)) +
    geom_line(aes(y = merit_mean)) +
    #geom_point(aes(y = merit_min), alpha = 0.1) +
    #geom_point(aes(y = merit_max), alpha = 0.1) +
    scale_color_manual(values = color_map) + 
    scale_y_continuous(trans = 'log2')
  
  ggplot(df[df$depth >= 375 & df$depth <= 413,], aes(x = depth)) +#, color = seed_classification)) + 
    geom_vline(aes(xintercept=392), alpha = 0.2) +
    geom_hline(aes(yintercept=df[df$depth == 392,]$correct_doors_mean), alpha = 0.2) +
    geom_point(aes(y = correct_doors_mean, color = seed_classification)) +
    geom_line(aes(y = correct_doors_mean)) +
    #geom_point(aes(y = merit_min), alpha = 0.1) +
    #geom_point(aes(y = merit_max), alpha = 0.1) +
    scale_color_manual(values = color_map)  
  
  ggplot(df[df$depth >= 375 & df$depth <= 413,], aes(x = depth)) +#, color = seed_classification)) + 
    geom_vline(aes(xintercept=392), alpha = 0.2) +
    geom_hline(aes(yintercept=df[df$depth == 392,]$incorrect_doors_mean), alpha = 0.2) +
    geom_point(aes(y = incorrect_doors_mean, color = seed_classification)) +
    geom_line(aes(y = incorrect_doors_mean)) +
    #geom_point(aes(y = merit_min), alpha = 0.1) +
    #geom_point(aes(y = merit_max), alpha = 0.1) +
    scale_color_manual(values = color_map)

  ggplot(df_raw, aes(xmin = origin_time, xmax = destruction_time, ymin = depth, ymax = depth + 1)) + 
    geom_hline(aes(yintercept = 600), alpha = 0.5, linetype = 'dashed') +
    geom_hline(aes(yintercept = 392), alpha = 0.5) +
    geom_rect() 
  ggsave('~/test.pdf', units = 'in', width = 30, height = 20)
  
  ggplot(df_raw, aes(x = depth, y = tot_orgs)) + 
    geom_col()
    
  ggplot(df_raw, aes(x = tot_orgs)) + 
    geom_histogram(binwidth = 5)
  
  
}



