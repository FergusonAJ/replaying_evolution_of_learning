rm(list = ls())

library(ggplot2)
library(dplyr)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

regenerate_data = F
plot_each_depth = F

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
focal_target_map = c(
  '86' = 484,
  '4' = 104,
  '15' = 279,
  '6' = 548
)

for(seed in c(86, 4, 6, 15)){
  focal_start = focal_start_map[as.character(seed)]
  focal_stop = focal_stop_map[as.character(seed)]
  focal_target = focal_target_map[as.character(seed)]
  seed_regenerate_data = regenerate_data
  cat('Seed: ', seed, '\n')
  # Create variables to make directory access easier
  #   and create missing directories
  data_dir = paste0('../data')
  base_rep_dir = paste0(data_dir, '/reps/', seed)
  replay_base_dir = paste0(base_rep_dir, '/replays')
  plot_dir = paste0('../plots/reps/', seed, '/replays/')
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  plot_dir_focal = paste0(plot_dir, '/focal')
  if(!dir.exists(plot_dir_focal)) dir.create(plot_dir_focal, recursive = T)
  plot_dir_initial = paste0(plot_dir, '/initial')
  if(!dir.exists(plot_dir_initial)) dir.create(plot_dir_initial, recursive = T)
  plot_dir_all = paste0(plot_dir, '/all')
  if(!dir.exists(plot_dir_all)) dir.create(plot_dir_all, recursive = T)
  plot_dir_depths = paste0(plot_dir, '/depths')
  if(!dir.exists(plot_dir_depths)) dir.create(plot_dir_depths, recursive = T)
  processed_data_dir = paste0(replay_base_dir, '/processed_data')
  if(!dir.exists(processed_data_dir)){
    dir.create(processed_data_dir, recursive=T)
    seed_regenerate_data = T
  }
 
  # If needed, load in all replay data, categorize it, and save to disk 
  if(seed_regenerate_data){
    df = read.csv(paste0(data_dir, '/combined_final_dominant_data.csv'))
    df$depth = 0
    
    for(depth in list.files(replay_base_dir)){
      if(depth == 'processed_data'){
        next
      }
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
    
    write.csv(df, paste0(processed_data_dir, '/processed_replay_data.csv'))
    write.csv(df_summary, paste0(processed_data_dir, '/processed_replay_summary.csv'))
    write.csv(classification_summary, paste0(processed_data_dir, '/processed_replay_classification.csv'))
  } else { # Else we're *not* regenerating data, so just load it from disk
    df = read.csv(paste0(processed_data_dir, '/processed_replay_data.csv'))
    df_summary = read.csv(paste0(processed_data_dir, '/processed_replay_summary.csv'))
    classification_summary = read.csv(paste0(processed_data_dir, '/processed_replay_classification.csv'))
  }
 
  # Attempt to load lineage data, too!
  df_lineage = NA
  if(file.exists(paste0(base_rep_dir, '/dominant_lineage_summary.csv'))){
    df_lineage = read.csv(paste0(base_rep_dir, '/dominant_lineage_summary.csv'))
    # Update classification name
    if(sum(df_lineage$seed_classification == 'Bet-hedged imprinting')){
      df_lineage[df_lineage$seed_classification == 'Bet-hedged imprinting',]$seed_classification_factor = seed_class_bet_hedged_learning
      df_lineage[df_lineage$seed_classification == 'Bet-hedged imprinting',]$seed_classification = seed_class_bet_hedged_learning
      
    }
    cat('Loaded lineage data from file\n')
  }
  
  plot_depth_counts = T
  if(plot_depth_counts){
    df_depth_counts = dplyr::summarize(dplyr::group_by(classification_summary, depth), count = sum(count)) 
    ggplot(df_depth_counts, aes(x = depth, y = count)) +
      geom_line()
    
    ggplot(df_depth_counts[df_depth_counts$depth > 0,], aes(x = depth, y = count)) +
      geom_line()
    
    max_nonzero_count = max(df_depth_counts[df_depth_counts$depth > 0,]$count)
    print(df_depth_counts[df_depth_counts$count != max_nonzero_count,])
    write.csv(df_depth_counts[df_depth_counts$count != max_nonzero_count,], paste0(replay_base_dir, '/missing_seeds.csv'))
    cat('Missing seed info saved to: ', paste0(replay_base_dir, '/missing_seeds.csv'), '\n')
    
    #count_allowance = 2
    #df_depth_counts = df_depth_counts[df_depth_counts$count >= max_nonzero_count - count_allowance,]
    #print('Preparing to remove depths due to insufficient data: ')
    #print(sort(unique(classification_summary[!(classification_summary$depth %in% df_depth_counts$depth),]$depth)))
    #classification_summary = classification_summary[classification_summary$depth %in% df_depth_counts$depth,]
  } 
  
  # Create masks
  mask_focal = classification_summary$depth %in% focal_start:focal_stop
  mask_initial = classification_summary$depth %% 50 == 0
  mask_learning = classification_summary$seed_classification == seed_class_learning
  
  # Area plots
  if(T){ 
    # Area - Counts - All
    ggplot(classification_summary, aes(x = depth, y = count, fill = seed_classification_factor)) +
      geom_area() +
      xlab('Phylogenetic depth') +
      ylab('Number of replicates') + 
      scale_fill_manual(values = color_map) +
      labs(fill = 'Classification') + 
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0))
    ggsave(paste0(plot_dir_all, '/replay_counts.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/replay_counts.png'), width = 9, height = 6, units = 'in')
    
    # Area - Fracs - All
    ggplot(classification_summary, aes(x = depth, y = frac, fill = seed_classification_factor)) +
      geom_area() +
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(fill = 'Classification') + 
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0))
    ggsave(paste0(plot_dir_all, '/replay_fracs.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/replay_fracs.png'), width = 9, height = 6, units = 'in')
    
    # Area - Fracs - Focal
    ggplot(classification_summary[mask_focal,], aes(x = depth, y = frac, fill = seed_classification_factor)) +
      geom_area() +
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(fill = 'Classification') + 
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0))
    ggsave(paste0(plot_dir_focal, '/replay_fracs__focal.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/replay_fracs__focal.png'), width = 9, height = 6, units = 'in')
    
    # Area - Fracs - Initial
    ggplot(classification_summary[mask_initial,], aes(x = depth, y = frac, fill = seed_classification_factor)) +
      geom_area() +
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(fill = 'Classification') + 
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0))
    ggsave(paste0(plot_dir_initial, '/replay_fracs__focal.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_initial, '/replay_fracs__focal.png'), width = 9, height = 6, units = 'in')
  }
  
  # Classification over time line plots
  if(T){
    # Classification over time - Counts - All
    ggplot(classification_summary, aes(x=depth, y = count, color = seed_classification_factor)) + 
      geom_line(size=1.2) + 
      geom_point(size = 2) + 
      scale_color_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Number of replicates') + 
      labs(color = 'Classification')
    ggsave(paste0(plot_dir_all, '/classification_counts_over_time.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/classification_counts_over_time.png'), width = 9, height = 6, units = 'in')
    
    # Classification over time - Fracs - All
    ggplot(classification_summary, aes(x=depth, y = frac, color = seed_classification_factor)) + 
      geom_line(size=1.2) + 
      geom_point(size = 2) + 
      scale_color_manual(values = color_map) + 
      scale_y_continuous(limits = c(0,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification')
    ggsave(paste0(plot_dir_all, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
    
    # Classification over time - Fracs - Focal
    ggplot(classification_summary[mask_focal,], aes(x=depth, y = frac, color = seed_classification_factor)) + 
      geom_line(size=1.2) + 
      geom_point(size = 2) + 
      scale_color_manual(values = color_map) + 
      scale_y_continuous(limits = c(0,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification')
    ggsave(paste0(plot_dir_focal, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
    
    # Classification over time - Fracs - Initial
    ggplot(classification_summary[mask_initial,], aes(x=depth, y = frac, color = seed_classification_factor)) + 
      geom_line(size=1.2) + 
      geom_point(size = 2) + 
      scale_color_manual(values = color_map) + 
      scale_y_continuous(limits = c(0,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification')
    ggsave(paste0(plot_dir_initial, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_initial, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
    
  }
  
  # Classification over time line plots with lineage data, if available
  if(is.data.frame(df_lineage)){ 
    # Classification over time w/ lineage data - Counts - All
    ggplot(classification_summary, aes(x=depth, y = count, color = seed_classification_factor)) + 
      geom_line(size=1.2) + 
      geom_point(size = 2) + 
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -15,ymax = -10, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      xlab('Phylogenetic depth') +
      ylab('Number of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_all, '/classifications_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/classifications_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    # Classification over time w/ lineage data - Fracs - All
    ggplot(classification_summary, aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size=1.2) + 
      geom_point(mapping=aes(y = frac), size = 2) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_all, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    # Classification over time w/ lineage data - Fracs - Focal
    mask_focal_lineage = df_lineage$depth >= focal_start & df_lineage$depth <= focal_stop
    ggplot(classification_summary[mask_focal,], aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size=1.2) + 
      geom_point(mapping=aes(y = frac), size = 2) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[mask_focal_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_focal, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    # Classification over time w/ lineage data - Fracs - Initial
    ggplot(classification_summary[mask_initial,], aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size=1.2) + 
      geom_point(mapping=aes(y = frac), size = 2) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_initial, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_initial, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
  }
  
 # Learning diffs (no initial)
  if(T){
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
    # Create masks
    mask_learning_diff_focal = df_learning_diffs$start_depth %in% focal_start:focal_stop
    
    # Learning diff line plot - All
    ggplot(df_learning_diffs, aes(x = start_depth, y = diff_frac)) + 
      geom_line(size = 1.01) + 
      geom_point(size = 2) + 
      geom_text(aes(y = diff_frac + 0.1, label = round(diff_frac, 2)))+
      geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) + 
      ylab('Difference (in fraction of reps.)') +
      xlab('Depth')
    ggsave(paste0(plot_dir_all, '/learning_diff_frac_lines.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/learning_diff_frac_lines.png'), width = 9, height = 6, units = 'in')
    
    # Learning diff line plot - Focal
    ggplot(df_learning_diffs[mask_learning_diff_focal,], aes(x = start_depth, y = diff_frac)) + 
      geom_line(size = 1.01) + 
      geom_point(size = 2) + 
      geom_text(aes(y = diff_frac + 0.1, label = round(diff_frac, 2)))+
      geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) +
      ylab('Difference (in fraction of reps.)') +
      xlab('Depth')
    ggsave(paste0(plot_dir_focal, '/learning_diff_frac_lines.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/learning_diff_frac_lines.png'), width = 9, height = 6, units = 'in')
    
    # Learning diff histogram - All
    ggplot(df_learning_diffs, aes(x = diff_frac)) + 
      geom_histogram(binwidth = 0.05) + 
      geom_vline(aes(xintercept=0)) + 
      xlab('Difference (in fraction of replicates)') + 
      ylab('Count')
    ggsave(paste0(plot_dir_all, '/learning_diff_frac_histogram.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/learning_diff_frac_histogram.png'), width = 9, height = 6, units = 'in')
    
    # Learning diff histogram - Focal
    ggplot(df_learning_diffs[mask_learning_diff_focal,], aes(x = diff_frac)) + 
      geom_histogram(binwidth = 0.05) + 
      geom_vline(aes(xintercept=0)) + 
      xlab('Difference (in fraction of replicates)') + 
      ylab('Count')
    ggsave(paste0(plot_dir_focal, '/learning_diff_frac_histogram.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/learning_diff_frac_histogram.png'), width = 9, height = 6, units = 'in')
    
    if(is.data.frame(df_lineage)){
      df_learning_diffs$merit_diff = NA
      df_learning_diffs$merit_quotient = NA
      df_learning_diffs$start_merit_mean = NA
      df_learning_diffs$finish_merit_mean = NA
      for(depth in learning_depths){
        if(depth == max(learning_depths)){
          next
        }
        start_depth = depth
        finish_depth = min(learning_depths[learning_depths > depth])
        start_merit = df_lineage[df_lineage$depth == start_depth,]$merit_mean
        finish_merit = df_lineage[df_lineage$depth == finish_depth,]$merit_mean
        diff = finish_merit - start_merit
        quotient = NA
        if(start_merit != 0){
          quotient = finish_merit / start_merit
        }
        df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$merit_diff = diff
        df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$merit_quotient = quotient
        df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$start_merit_mean = start_merit
        df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$finish_merit_mean = finish_merit
      }
    }
    ggplot(df_learning_diffs[mask_learning_diff_focal & df_learning_diffs$start_depth != focal_stop,], aes(x = diff_frac, y = merit_quotient)) + 
      geom_hline(aes(yintercept=1), alpha = 0.5) +
      geom_vline(aes(xintercept=0), alpha = 0.5) +
      geom_point(alpha = 0.5) 
    ggplot(df_learning_diffs[mask_learning_diff_focal & df_learning_diffs$start_depth != focal_stop,], aes(x = diff_frac, y = merit_diff)) + 
      geom_hline(aes(yintercept=0), alpha = 0.5) +
      geom_vline(aes(xintercept=0), alpha = 0.5) +
      geom_point(alpha = 0.5) 
    ggplot(df_learning_diffs, aes(x = diff_frac, y = merit_quotient)) + 
      geom_hline(aes(yintercept=1), alpha = 0.5) +
      geom_vline(aes(xintercept=0), alpha = 0.5) +
      geom_point(alpha = 0.5) +
      scale_y_continuous(trans = 'log2')
    ggplot(df_learning_diffs, aes(x = diff_frac, y = merit_diff)) + 
      geom_hline(aes(yintercept=0), alpha = 0.5) +
      geom_vline(aes(xintercept=0), alpha = 0.5) +
      geom_point(alpha = 0.5)  + 
      scale_y_continuous(trans = 'log2')
    ggplot(df_learning_diffs[mask_learning_diff_focal & df_learning_diffs$start_depth != focal_stop,], aes(x = start_depth, y = merit_quotient)) + 
      geom_hline(aes(yintercept=1), alpha = 0.5) +
      geom_line()
    ggplot(df_learning_diffs[df_learning_diffs$start_depth > 0,], aes(x = start_depth, y = merit_quotient)) + 
      geom_hline(aes(yintercept=1), alpha = 0.5) +
      geom_line() +
      scale_y_continuous(trans = 'log2')
  }
  
  # Learning frac over time
  if(is.data.frame(df_lineage)){ 
    df_learning_summary = classification_summary[classification_summary$seed_classification == seed_class_learning,]
    df_learning_summary$lineage_classification = NA
    for(depth in unique(df_learning_summary$depth)){
      df_learning_summary[df_learning_summary$depth == depth,]$lineage_classification = df_lineage[df_lineage$depth == depth,]$seed_classification
    }
    # Create masks
    mask_learning_summary_focal = df_learning_summary$depth %in% focal_start:focal_stop
    mask_learning_summary_initial = df_learning_summary$depth %% 50 == 0
    
    # All
    ggplot(df_learning_summary, aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size = 1.05) + 
      geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_all, '/learning_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_all, '/learning_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    # Focal
    ggplot(df_learning_summary[mask_learning_summary_focal,], aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size = 1.05) + 
      geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
      geom_rect(data=df_lineage[mask_focal_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_focal, '/learning_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/learning_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    # Initial
    ggplot(df_learning_summary[mask_learning_summary_initial,], aes(x=depth, color = seed_classification_factor)) + 
      geom_line(mapping=aes(y = frac), size = 1.05) + 
      geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
      geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,1)) +
      xlab('Phylogenetic depth') +
      ylab('Fraction of replicates') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification')
    ggsave(paste0(plot_dir_initial, '/learning_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_initial, '/learning_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
    
    # Learning classification over time - Fracs - Focal
    ggplot(df_learning_summary[mask_learning_summary_focal,], aes(x=depth)) + 
      geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = 1.05) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_rect(data=df_lineage[mask_focal_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(legend.position = 'none')
    ggsave(paste0(plot_dir_focal, '/learning_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/learning_frac_over_time.png'), width = 9, height = 6, units = 'in')
    
    ggplot(df_learning_summary[mask_learning_summary_focal,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start, xmax=focal_stop, ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      #annotate("rect", xmin=focal_start, xmax=focal_stop, ymin=-Inf, ymax=Inf, alpha=0.3, fill="#9ae2e6") +
      geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = 1.05) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_rect(data=df_lineage[mask_focal_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(legend.position = 'none')
    ggsave(paste0(plot_dir_focal, '/learning_frac_over_time_bg.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_focal, '/learning_frac_over_time_bg.png'), width = 9, height = 6, units = 'in')
    
    # Learning classification over time - Fracs - Initial
    ggplot(df_learning_summary[mask_learning_summary_initial,], aes(x=depth)) + 
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = 1.05) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(legend.position = 'none')
    ggsave(paste0(plot_dir_initial, '/learning_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_initial, '/learning_frac_over_time.png'), width = 9, height = 6, units = 'in')
    
    ggplot(df_learning_summary[mask_learning_summary_initial,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start, xmax=focal_stop, ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      #annotate("rect", xmin=focal_start, xmax=focal_stop, ymin=-Inf, ymax=Inf, alpha=0.3, fill="#9ae2e6") +
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = 1.05) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = 16)) +
      theme(axis.title = element_text(size = 18)) +
      theme(legend.position = 'none')
    ggsave(paste0(plot_dir_initial, '/learning_frac_over_time_bg.pdf'), width = 9, height = 6, units = 'in')
    ggsave(paste0(plot_dir_initial, '/learning_frac_over_time_bg.png'), width = 9, height = 6, units = 'in')
    
    write.csv(df_learning_summary, paste0(processed_data_dir, '/processed_learning_summary.csv'))
  }
  
  # Plot classification at each depth?
  if(plot_each_depth){
    for(depth in unique(classification_summary$depth)){
      ggplot(classification_summary[classification_summary$depth == depth,], aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
        geom_col() + 
        geom_text(aes(y = count + 3, label = count)) + 
        scale_fill_manual(values = color_map) + 
        xlab('Classification') + 
        ylab('Number of replicates') + 
        theme(legend.position = 'none')
      ggsave(paste0(plot_dir_depths, '/classification_depth_', depth, '.pdf'), width = 9, height = 6, units = 'in')
      ggsave(paste0(plot_dir_depths, '/classification_depth_', depth, '.png'), width = 9, height = 6, units = 'in')
    }
  }
  
} # End depth for loop

