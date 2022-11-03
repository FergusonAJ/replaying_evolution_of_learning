rm(list = ls())

library(ggplot2)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

for(seed in 208:208){
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
  print(paste0('Plotting seed: ', seed))
  plot_dir = paste0('../plots/reps/', seed)
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  
  ggplot(df, aes(x = depth)) + 
    geom_point(aes(y = accuracy_mean)) +
    geom_point(aes(y = accuracy_min), alpha = 0.1) +
    geom_point(aes(y = accuracy_max), alpha = 0.1) 
  ggsave(paste0(plot_dir, '/accuracy.pdf'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth)) + 
    geom_point(aes(y = correct_doors_mean)) +
    geom_point(aes(y = correct_doors_min), alpha = 0.1) +
    geom_point(aes(y = correct_doors_max), alpha = 0.1) 
  ggsave(paste0(plot_dir, '/correct_doors.pdf'), width = 9, height = 6, units = 'in')
  #
  #ggplot(df, aes(x = depth)) + 
  #  geom_point(aes(y = correct_doors_mean)) +
  #  geom_point(aes(y = correct_doors_min), alpha = 0.1) +
  #  geom_point(aes(y = correct_doors_max), alpha = 0.1) +
  #  geom_point(aes(y = incorrect_doors_mean, color = 'red')) +
  #  geom_point(aes(y = incorrect_doors_min, color = 'red'), alpha = 0.1) +
  #  geom_point(aes(y = incorrect_doors_max, color = 'red'), alpha = 0.1)
  #
  #ggplot(df, aes(x = depth)) + 
  #  geom_point(aes(y = correct_exits_mean)) +
  #  geom_point(aes(y = correct_exits_min), alpha = 0.1) +
  #  geom_point(aes(y = correct_exits_max), alpha = 0.1)
  
  ggplot(df, aes(x = depth)) + 
    geom_point(aes(y = merit_mean)) +
    geom_point(aes(y = merit_min), alpha = 0.1) +
    geom_point(aes(y = merit_max), alpha = 0.1) 
  ggsave(paste0(plot_dir, '/merit.pdf'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth)) + 
    geom_point(aes(y = genome_length)) +
    scale_color_manual(values = color_map)
  ggsave(paste0(plot_dir, '/genome_length.pdf'), width = 8, height = 6, units = 'in')
}

