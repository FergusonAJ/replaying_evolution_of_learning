rm(list = ls())

library(ggplot2)
library(dplyr)
source('../../../../global_shared_files/constant_vars__two_cues.R')
source('../../../../global_shared_files/shared_funcs__two_cues.R')

seed = 28
for(seed in c(28)){
  cat('Seed: ', seed, '\n')
  data_dir = paste0('../data')
  base_rep_dir = paste0(data_dir, '/reps/', seed)
  replay_base_dir = paste0(base_rep_dir, '/new_replays')
  plot_dir = paste0('../plots/reps/', seed, '/nonzero/')
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  df_lineage = NA
  if(file.exists(paste0(base_rep_dir, '/dominant_lineage_summary.csv'))){
    df_lineage = read.csv(paste0(base_rep_dir, '/dominant_lineage_summary.csv'))
    cat('Loaded lineage data\n')
  }
  
  df = read.csv(paste0(data_dir, '/combined_final_dominant_data.csv'))
  df$depth = 0
  
  for(depth in list.files(replay_base_dir)){
    print(depth)
    replay_dir = paste0(replay_base_dir, '/', depth)
    df_tmp = read.csv(paste0(replay_dir, '/combined_final_dominant_data.csv'))
    if(nrow(df_tmp) <= 1){
      next
    }
    df_tmp$depth = depth
    df = rbind(df, df_tmp)
  }
  df$depth = as.numeric(df$depth)
  
  df = classify_individual_trials(df)
  df = classify_seeds(df)
  df_summary = summarize_final_dominant_org_data(df)
  classification_summary = summarize_classifications(df_summary)
                                
  ggplot(df_summary[df_summary$depth != 0,], aes(x = depth, y = accuracy_mean, color = seed_classification)) + 
    geom_point() + 
    scale_color_manual(values = color_map) + 
    scale_y_continuous(limits = c(0,1))
  
  classification_summary$frac = 0
  for(depth in unique(classification_summary$depth)){
    mask = classification_summary$depth == depth
    for(classification_string in seed_classifcation_order_vec){
      if(!(classification_string %in% classification_summary[mask,]$seed_classification)){
        cat(depth, ' ', classification_string, '\n')
        classification_summary[nrow(classification_summary) + 1,] = list(depth, classification_string, 0, NA, NA, classification_string, 0)
        mask = classification_summary$depth == depth
      }
    }
    classification_summary[mask,]$frac = classification_summary[mask,]$count / sum(classification_summary[mask,]$count)
  }
  
  ggplot(classification_summary[classification_summary$depth != 0,], aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
    geom_col() +
    geom_text(aes(label = count, y = count + 5)) +
    facet_grid(cols = vars(as.factor(depth))) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(0,205)) +
    ylab('Number of replicates') + 
    xlab('Classification') + 
    labs(fill = 'Classification') +
    theme(axis.text.x = element_blank())
  ggsave(paste0(plot_dir, '/replay_cols.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/replay_cols.png'), width = 9, height = 6, units = 'in')
  
  ggplot(classification_summary[classification_summary$depth != 0,], aes(x = depth, y = count, fill = seed_classification_factor)) +
    geom_area() +
    #geom_vline(aes(xintercept=38), alpha = 0.1) +
    #geom_vline(aes(xintercept=75), alpha = 0.1) +
    #geom_vline(aes(xintercept=113), alpha = 0.1) +
    #geom_vline(aes(xintercept=150), alpha = 0.1) +
    #geom_vline(aes(xintercept=188), alpha = 0.1) +
    #geom_vline(aes(xintercept=225), alpha = 0.1) +
    #geom_vline(aes(xintercept=263), alpha = 0.1) +
    #geom_vline(aes(xintercept=300), alpha = 0.1) +
    #geom_vline(aes(xintercept=338), alpha = 0.1) +
    #geom_vline(aes(xintercept=375), alpha = 0.1) +
    #geom_vline(aes(xintercept=413), alpha = 0.1) +
    #geom_vline(aes(xintercept=450), alpha = 0.1) +
    #geom_vline(aes(xintercept=488), alpha = 0.1) +
    #geom_vline(aes(xintercept=525), alpha = 0.1) +
    #geom_vline(aes(xintercept=563), alpha = 0.1) +
    #geom_vline(aes(xintercept=600), alpha = 0.1) +
    xlab('Phylogenetic depth') +
    ylab('Number of replicates') + 
    scale_fill_manual(values = color_map) +
    labs(fill = 'Classification') + 
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0))
  ggsave(paste0(plot_dir, '/replay_counts.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/replay_counts.png'), width = 9, height = 6, units = 'in')
  
  ggplot(classification_summary[classification_summary$depth != 0,], aes(x = depth, y = frac, fill = seed_classification_factor)) +
    geom_area() +
    #geom_vline(aes(xintercept=38), alpha = 0.1) +
    #geom_vline(aes(xintercept=75), alpha = 0.1) +
    #geom_vline(aes(xintercept=113), alpha = 0.1) +
    #geom_vline(aes(xintercept=150), alpha = 0.1) +
    #geom_vline(aes(xintercept=188), alpha = 0.1) +
    #geom_vline(aes(xintercept=225), alpha = 0.1) +
    #geom_vline(aes(xintercept=263), alpha = 0.1) +
    #geom_vline(aes(xintercept=300), alpha = 0.1) +
    #geom_vline(aes(xintercept=338), alpha = 0.1) +
    #geom_vline(aes(xintercept=375), alpha = 0.1) +
    #geom_vline(aes(xintercept=413), alpha = 0.1) +
    #geom_vline(aes(xintercept=450), alpha = 0.1) +
    #geom_vline(aes(xintercept=488), alpha = 0.1) +
    #geom_vline(aes(xintercept=525), alpha = 0.1) +
    #geom_vline(aes(xintercept=563), alpha = 0.1) +
    #geom_vline(aes(xintercept=600), alpha = 0.1) +
    scale_fill_manual(values = color_map) + 
    xlab('Phylogenetic depth') +
    ylab('Fraction of replicates') + 
    labs(fill = 'Classification') + 
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0))
  ggsave(paste0(plot_dir, '/replay_fracs.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/replay_fracs.png'), width = 9, height = 6, units = 'in')
  
  ggplot(classification_summary[classification_summary$depth != 0,], aes(x=depth, y = count, color = seed_classification_factor)) + 
    geom_line(size=1.2) + 
    geom_point(size = 2) + 
    scale_color_manual(values = color_map) + 
    xlab('Phylogenetic depth') +
    ylab('Number of replicates') + 
    labs(color = 'Classification')
  ggsave(paste0(plot_dir, '/classifications_over_time.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/classifications_over_time.png'), width = 9, height = 6, units = 'in')
  
  ggplot(classification_summary[classification_summary$depth != 0,], aes(x=depth, y = frac, color = seed_classification_factor)) + 
    geom_line(size=1.2) + 
    geom_point(size = 2) + 
    scale_color_manual(values = color_map) + 
    xlab('Phylogenetic depth') +
    ylab('Fraction of replicates') + 
    labs(color = 'Classification')
  ggsave(paste0(plot_dir, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
  
  if(is.data.frame(df_lineage)){ 
    ggplot(classification_summary, aes(x=depth, y = count, color = seed_classification_factor)) + 
      geom_line(size=1.2) + 
      geom_point(size = 2) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -15,ymax = -10, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Number of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir, '/classifications_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/classifications_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    ggplot(classification_summary, aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size=1.2) + 
      geom_point(mapping=aes(y = frac), size = 2) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
  }
  # Calculate the increasing in learning from each time step
  learning_mask = classification_summary$seed_classification == seed_class_learning
  learning_classification_summary = classification_summary[learning_mask,]
  learning_depths = unique(learning_classification_summary$depth)
  df_learning_diffs = data.frame(data = matrix(nrow = 0, ncol = 8))
  colnames(df_learning_diffs) = c('start_depth', 'finish_depth', 'start_reps', 'finish_reps', 'diff', 'start_frac', 'finish_frac', 'diff_frac')
  for(depth in learning_depths){
    if(depth == max(learning_depths)){
      next
    }
    start_depth = depth
    finish_depth = min(learning_depths[learning_depths > depth])
    start_learning_reps = learning_classification_summary[learning_classification_summary$depth == start_depth,]$count
    finish_learning_reps = learning_classification_summary[learning_classification_summary$depth == finish_depth,]$count
    diff = finish_learning_reps - start_learning_reps
    start_frac = learning_classification_summary[learning_classification_summary$depth == start_depth,]$frac
    finish_frac = learning_classification_summary[learning_classification_summary$depth == finish_depth,]$frac
    diff_frac = finish_frac - start_frac
    df_learning_diffs[nrow(df_learning_diffs) +1,] = c(start_depth, finish_depth, start_learning_reps, finish_learning_reps, diff, start_frac, finish_frac, diff_frac)
  }
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth != 0,], aes(x = finish_depth, y = diff)) + 
    geom_line(size = 1.01) + 
    geom_point(size = 2) + 
    geom_text(aes(y = diff + 5, label = diff))+
    geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5)
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth != 0,], aes(x = finish_depth, y = diff_frac)) + 
    geom_line(size = 1.01) + 
    geom_point(size = 2) + 
    geom_text(aes(y = diff_frac + 0.1, label = round(diff_frac, 2)))+
    geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) + 
    ylab('Difference (in fraction of reps.)') +
    xlab('Depth')
  ggsave(paste0(plot_dir, '/diff_frac_lines.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/diff_frac_lines.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth %in% 375:413,], aes(x = start_depth, y = diff_frac)) + 
    geom_line(size = 1.01) + 
    geom_point(size = 2) + 
    geom_text(aes(y = diff_frac + 0.1, label = round(diff_frac, 2)))+
    geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) +
    ylab('Difference (in fraction of reps.)') +
    xlab('Depth')
  ggsave(paste0(plot_dir, '/diff_frac_lines__focal.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/diff_frac_lines__focal.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth != 0,], aes(xmin = start_depth, xmax = finish_depth, ymin = diff_frac-0.05, ymax = diff_frac+0.05)) + 
    geom_rect() +
    geom_text(aes(x=(start_depth + finish_depth)/2, y = diff_frac + 0.0625, label = round(diff_frac, 2))) +
    geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) +
    ylab('Difference (in fraction of reps.)') +
    xlab('Depth')
  ggsave(paste0(plot_dir, '/diff_frac_rects.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/diff_frac_rects.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth %in% 375:412,], aes(xmin = start_depth, xmax = finish_depth, ymin = diff_frac-0.05, ymax = diff_frac+0.05)) + 
    geom_rect() +
    geom_text(aes(x=(start_depth + finish_depth)/2, y = diff_frac + 0.0625, label = round(diff_frac, 2))) +
    geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) +
    ylab('Difference (in fraction of reps.)') +
    xlab('Depth')
  ggsave(paste0(plot_dir, '/diff_frac_rects__focal.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/diff_frac_rects__focal.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth != 0,], aes(x = diff_frac)) + 
    geom_histogram(binwidth = 0.05) + 
    geom_vline(aes(xintercept=0)) + 
    xlab('Difference (in fraction of replicates)') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/diff_frac_histogram.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/diff_frac_histogram.png'), width = 9, height = 6, units = 'in')
  
  ggplot(df_learning_diffs[df_learning_diffs$start_depth %in% 375:412,], aes(x = diff_frac)) + 
    geom_histogram(binwidth = 0.05) + 
    geom_vline(aes(xintercept=0)) + 
    xlab('Difference (in fraction of replicates)') + 
    ylab('Count')
  ggsave(paste0(plot_dir, '/diff_frac_histogram__focal.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/diff_frac_histogram__focal.png'), width = 9, height = 6, units = 'in')
  
  
  if(is.data.frame(df_lineage)){ 
    df_learning_summary = classification_summary[classification_summary$seed_classification == seed_class_learning,]
    df_learning_summary$lineage_classification = NA
    for(depth in unique(df_learning_summary$depth)){
      df_learning_summary[df_learning_summary$depth == depth,]$lineage_classification = df_lineage[df_lineage$depth == depth,]$seed_classification
    }
    ggplot(df_learning_summary, aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size = 1.05) + 
      geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir, '/learning_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/learning_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    ggplot(df_learning_summary[df_learning_summary$depth >= 375 & df_learning_summary$depth <= 413,], aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size = 1.05) + 
      geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      #geom_rect(data=df_lineage[df_lineage$depth >= 375 & df_lineage$depth <= 413,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(0,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir, '/focal_window_learning_frac.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/focal_window_learning_frac.png'), width = 9, height = 6, units = 'in')
    
    ggplot(classification_summary[classification_summary$depth >= 375 & classification_summary$depth <= 413,], aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size = 1.05) + 
      geom_point(mapping=aes(y = frac), size = 2.5) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      #geom_rect(data=df_lineage[df_lineage$depth >= 375 & df_lineage$depth <= 413,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(0,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir, '/focal_window_frac.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/focal_window_frac.png'), width = 9, height = 6, units = 'in')
    
  }
  for(depth in unique(classification_summary$depth)){
    ggplot(classification_summary[classification_summary$depth == depth,], aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
      geom_col() + 
      geom_text(aes(y = count + 3, label = count)) + 
      scale_fill_manual(values = color_map) + 
      xlab('Classification') + 
      ylab('Number of replicates') + 
      theme(legend.position = 'none')
    ggsave(paste0(plot_dir, '/classification_depth_', depth, '.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir, '/classification_depth_', depth, '.png'), width = 9, height = 6, units = 'in')
  }
}


focal_window = df_learning_diffs[df_learning_diffs$diff == max(df_learning_diffs$diff),]
for(depth in seq(focal_window$finish_depth, focal_window$start_depth, -1)){
  cat(depth, ' ')
}
cat('\n')
