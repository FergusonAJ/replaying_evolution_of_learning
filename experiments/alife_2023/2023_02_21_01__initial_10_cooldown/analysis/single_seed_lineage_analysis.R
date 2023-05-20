rm(list = ls())

library(ggplot2)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')

# Make sure plot/reps exists
if(!dir.exists('../plots/reps')){
  dir.create('../plots/reps')
}

focal_start_map = c(
  '86' = 400,
  '4' = 50, 
  '15' = 250,
  '6' = 500
)
focal_stop_map = c(
  '86' = 500,
  '4' = 150,
  '15' = 300,
  '6' = 550
)
focal_mut_map = c(
  '86' = 484,
  '4' = 104, 
  '15' = 279,
  '6' = 548
)


for(seed in c(86, 4, 6, 15)){#}, 29, 30, 94, 100)){ 
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
  # Update classification name
  if(sum(df$seed_classification == 'Bet-hedged imprinting')){
    df[df$seed_classification == 'Bet-hedged imprinting',]$seed_classification_factor = seed_class_bet_hedged_learning
    df[df$seed_classification == 'Bet-hedged imprinting',]$seed_classification = seed_class_bet_hedged_learning
    
  }
  cat('Learning first evolved at depth: ', min(df[df$seed_classification == seed_class_learning,]$depth), '\n')
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
  plot_dir = paste0('../plots/reps/', seed, '/lineage')
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = accuracy_mean)) +
    geom_point(aes(y = accuracy_min), alpha = 0.1) +
    geom_point(aes(y = accuracy_max), alpha = 0.1) + 
    scale_color_manual(values = color_map) +
    ylab('Accuracy (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/accuracy.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/accuracy.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = correct_doors_mean)) +
    geom_point(aes(y = correct_doors_min), alpha = 0.1) +
    geom_point(aes(y = correct_doors_max), alpha = 0.1) + 
    scale_color_manual(values = color_map) +
    ylab('Correct doors (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/correct_doors.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/correct_doors.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = incorrect_doors_mean)) +
    geom_point(aes(y = incorrect_doors_min), alpha = 0.1) +
    geom_point(aes(y = incorrect_doors_max), alpha = 0.1) + 
    scale_color_manual(values = color_map) +
    ylab('Incorrect doors (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/incorrect_doors.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/incorrect_doors.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = merit_mean)) +
    geom_point(aes(y = merit_min), alpha = 0.1) +
    geom_point(aes(y = merit_max), alpha = 0.1) +
    scale_color_manual(values = color_map) + 
    scale_y_continuous(trans = 'log2') +
    ylab('Merit (min, mean, max)') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/merit.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/merit.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth, color = seed_classification)) +
    geom_line(aes(y = merit_mean)) + 
    scale_y_continuous(trans = 'log2') +
    scale_color_manual(values = color_map) +
    ylab('Mean merit') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/merit_line.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/merit_line.png'), width = 8, height = 6, units = 'in')
  
  ggplot(df, aes(x = depth)) +
    geom_line(aes(y = merit_mean)) + 
    geom_point(aes(y = merit_mean, color = seed_classification), size = 0.25) + 
    scale_y_continuous(trans = 'log2') +
    scale_color_manual(values = color_map) +
    ylab('Mean merit') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/merit_line_with_points.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/merit_line_with_points.png'), width = 8, height = 6, units = 'in')
  
  
    
  
  ggplot(df, aes(x = depth, color = seed_classification)) + 
    geom_point(aes(y = genome_length)) +
    scale_color_manual(values = color_map) +
    ylab('Genome length') + 
    xlab('Phylogenetic depth (from ancestor)')
  ggsave(paste0(plot_dir, '/genome_length.pdf'), width = 8, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/genome_length.png'), width = 8, height = 6, units = 'in')
  
 
  # Plot focal window, if applicable 
  focal_start = focal_start_map[as.character(seed)]
  focal_stop = focal_stop_map[as.character(seed)]
  focal_mut = focal_mut_map[as.character(seed)]
  if(!is.na(focal_start) & !is.na(focal_stop) & !is.na(focal_mut)){
    mask_focal = df$depth >= focal_start & df$depth <= focal_stop
    
    focal_mut_accuracy = df[df$depth == focal_mut,]$accuracy_mean
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
      geom_hline(aes(yintercept = focal_mut_accuracy), linetype = 'dashed', alpha = 0.5) +
      geom_point(aes(y = accuracy_mean, color = seed_classification)) +
      geom_line(aes(y = accuracy_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Mean accuracy') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/accuracy__focal.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/accuracy__focal.png'), width = 8, height = 6, units = 'in')
      
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_point(aes(y = merit_mean, color = seed_classification)) +
      geom_line(aes(y = merit_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Mean merit') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/merit__focal.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit__focal.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_point(aes(y = merit_mean, color = seed_classification)) +
      geom_line(aes(y = merit_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Mean merit') + 
      xlab('Phylogenetic depth (from ancestor)') +
      scale_y_continuous(trans = 'log2')
    ggsave(paste0(plot_dir, '/merit_log2__focal.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit_log2__focal.png'), width = 8, height = 6, units = 'in')
    
    focal_mut_merit = df[df$depth == focal_mut,]$merit_mean
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
      geom_hline(aes(yintercept = focal_mut_merit), linetype = 'dashed', alpha = 0.5) +
      geom_point(aes(y = merit_mean, color = seed_classification)) +
      geom_line(aes(y = merit_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Mean merit') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/merit__focal_cross.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit__focal_cross.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
      geom_hline(aes(yintercept = focal_mut_merit), linetype = 'dashed', alpha = 0.5) +
      geom_point(aes(y = merit_mean, color = seed_classification)) +
      geom_line(aes(y = merit_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Mean merit') + 
      xlab('Phylogenetic depth (from ancestor)') +
      scale_y_continuous(trans = 'log2')
    ggsave(paste0(plot_dir, '/merit_log2__focal_cross.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit_log2__focal_cross.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
      geom_hline(aes(yintercept = 1), linetype = 'dashed', alpha = 0.5) +
      geom_point(aes(y = merit_mean/focal_mut_merit, color = seed_classification)) +
      geom_line(aes(y = merit_mean/focal_mut_merit)) +
      scale_color_manual(values = color_map) +
      ylab('Relative mean merit') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/merit__focal_cross_relative.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit__focal_cross_relative.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df[mask_focal,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
      geom_hline(aes(yintercept = 1), linetype = 'dashed', alpha = 0.5) +
      geom_point(aes(y = log(merit_mean,1.1)/log(focal_mut_merit,1.1), color = seed_classification)) +
      geom_line(aes(y = log(merit_mean,1.1)/log(focal_mut_merit,1.1))) +
      scale_color_manual(values = color_map) +
      ylab('Relative mean merit') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/merit_log__focal_cross_relative.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit_log__focal_cross_relative.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df, aes(x = depth)) +#, color = seed_classification)) + 
      geom_vline(aes(xintercept = focal_mut), linetype = 'dashed', alpha = 0.5) +
      geom_hline(aes(yintercept = focal_mut_merit), linetype = 'dashed', alpha = 0.5) +
      geom_point(aes(y = merit_mean, color = seed_classification)) +
      geom_line(aes(y = merit_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Mean merit') + 
      xlab('Phylogenetic depth (from ancestor)') +
      scale_y_continuous(trans = 'log2')
    ggsave(paste0(plot_dir, '/merit_log2__cross.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/merit_log2__cross.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df[df$depth >= focal_start & df$depth <= focal_stop,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_point(aes(y = correct_doors_mean, color = seed_classification)) +
      geom_line(aes(y = correct_doors_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Correct doors') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/correct_doors__focal.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/correct_doors__focal.png'), width = 8, height = 6, units = 'in')
    
    ggplot(df[df$depth >= focal_start & df$depth <= focal_stop,], aes(x = depth)) +#, color = seed_classification)) + 
      geom_point(aes(y = incorrect_doors_mean, color = seed_classification)) +
      geom_line(aes(y = incorrect_doors_mean)) +
      scale_color_manual(values = color_map) +
      ylab('Incorrect doors') + 
      xlab('Phylogenetic depth (from ancestor)')
    ggsave(paste0(plot_dir, '/incorrect_doors__focal.pdf'), width = 8, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/incorrect_doors__focal.png'), width = 8, height = 6, units = 'in')
  }
  
  fitness_filename = paste0('../data/reps/', seed, '/fitness.csv') 
  max_org_filename = paste0('../data/reps/', seed, '/max_org.csv') 
  get_origin_time = function(v, df_raw){
    depth = as.numeric(v['depth'])
    df_tmp = df_raw[df_raw$depth == depth,]
    if(nrow(df_tmp) == 0){
      return(0.01)
    }
    return(as.numeric(df_tmp[1,]$origin_time))
  }
  df$origin_time = apply(df, 1, get_origin_time, df_raw)
  if(file.exists(fitness_filename) && file.exists(max_org_filename)){
    df_fitness = read.csv(fitness_filename)
    df_fitness$update = 1:nrow(df_fitness)
    df_max_org = read.csv(max_org_filename)
    df_max_org$update = 1:nrow(df_max_org)
    ggplot(df, aes()) +
      geom_line(aes(x = origin_time, y = merit_mean, color = 'Lineage')) +
      geom_line(data = df_fitness, aes(x = update, y = merit_mean, color = 'Pop mean merit')) + 
      geom_line(data = df_max_org, aes(x = update, y = merit, color = 'Max org merit')) + 
      scale_y_continuous(trans = 'log2')
  }
  
}


ggplot(df[df$depth %in% 540:550,], aes(x = depth, y = merit_mean)) + 
  geom_line() + 
  geom_text(aes(y = 0, label = signif(merit_mean, 1))) +
  geom_vline(aes(xintercept = 548), linetype='dashed') + 
  theme(axis.text.x = element_text(angle = 45))
