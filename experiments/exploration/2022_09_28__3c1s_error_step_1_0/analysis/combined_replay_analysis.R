rm(list = ls())

library(ggplot2)
library(dplyr)
source('../../../../global_shared_files/constant_vars__two_cues.R')
source('../../../../global_shared_files/shared_funcs__two_cues.R')

seed = 82
for(seed in c(7,69,82,67)){
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
  
  
  lineage_data_filename = paste0('../data/reps/', seed, '/dominant_lineage_summary.csv') 
  df_lineage = read.csv(lineage_data_filename)
  
  df_lineage = df_lineage[df_lineage$depth %in% unique(df$depth),]
  df_lineage$merit_mean_frac = df_lineage$merit_mean / max(df_lineage$merit_mean)
  
  ggplot(classification_summary[classification_summary$seed_classification == seed_class_learning,], aes(x = depth)) + 
    geom_line(aes(y = pct, linetype = as.factor('Percentage of replicates that evolved learning'))) + 
    geom_line(data = df_lineage, aes(y = merit_mean_frac, linetype = as.factor('Mean merit (relative to max of mean)'))) + 
    xlab('Depth') +
    ylab('') +
    theme(legend.position = 'bottom') +
    theme(legend.title = element_blank())
  ggsave(paste0(plot_dir, '/replay_vs_merit.pdf'), width = 9, height = 6, units = 'in')
  ggsave(paste0(plot_dir, '/replay_vs_merit.png'), width = 9, height = 6, units = 'in')
}
