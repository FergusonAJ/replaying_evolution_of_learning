rm(list = ls())

library(ggplot2)
library(dplyr)
source('../shared_files/constant_vars.R')
source('../shared_files/shared_funcs.R')

for(seed in c(7,69,82)){
  cat('Seed: ', seed, '\n')
  data_dir = paste0('../data')
  base_rep_dir = paste0(data_dir, '/reps/', seed)
  replay_base_dir = paste0(base_rep_dir, '/replays')
  plot_dir = paste0('../plots/reps/', seed)
  if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T)
  
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
                                
  ggplot(df_summary, aes(x = depth, y = accuracy_mean, color = seed_classification)) + 
    geom_point() + 
    scale_color_manual(values = color_map) + 
    scale_y_continuous(limits = c(0,1))
  
  classification_summary$pct = 0
  for(depth in unique(classification_summary$depth)){
    mask = classification_summary$depth == depth
    for(classification_string in seed_classifcation_order_vec){
      if(!(classification_string %in% classification_summary[mask,]$seed_classification)){
        cat(depth, ' ', classification_string, '\n')
        classification_summary[nrow(classification_summary) + 1,] = list(depth, classification_string, 0, NA, NA, classification_string, 0)
        mask = classification_summary$depth == depth
      }
    }
    classification_summary[mask,]$pct = classification_summary[mask,]$count / sum(classification_summary[mask,]$count)
  }
  
  ggplot(classification_summary, aes(xi = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
    geom_col() +
    facet_grid(cols = vars(as.factor(depth))) + 
    scale_fill_manual(values = color_map) + 
    scale_y_continuous(limits = c(0,100)) +
    theme(axis.title.x = element_blank(), 
          axis.text.x = element_blank()
    )
  
  ggplot(classification_summary, aes(x = depth, y = count, fill = seed_classification_factor)) +
    geom_area() +
    xlab('Phylogenetic depth') +
    ylab('Number of replicates') + 
    scale_fill_manual(values = color_map) +
    labs(fill = 'Classification') + 
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0))
  ggsave(paste0(plot_dir, '/replay_counts.pdf'), width = 9, height = 6, units = 'in')
  
  ggplot(classification_summary, aes(x = depth, y = pct, fill = seed_classification_factor)) +
    geom_area() +
    scale_fill_manual(values = color_map) + 
    xlab('Phylogenetic depth') +
    ylab('Fraction of replicates') + 
    labs(fill = 'Classification') + 
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0))
  ggsave(paste0(plot_dir, '/replay_fracs.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/replay_fracs.png'), width = 9, height = 6, units = 'in')
}