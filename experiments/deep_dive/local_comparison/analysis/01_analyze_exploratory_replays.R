rm(list = ls())

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'exploratory_replay_data_base.csv')
df = read.csv(base_data_filename)

# General masks
learning_mask = df$is_learning

# Determine which exploratory replays were unnecessary
df$is_necessary_exploratory_replay = T
for(true_seed in unique(df$true_seed)){
  true_seed_mask = df$true_seed == true_seed
  depth_vec = sort(unique(df[true_seed_mask,]$depth), decreasing = T)
  for(depth in depth_vec){
    frac = df[true_seed_mask & learning_mask & df$depth == depth,]$frac
    if(frac <= exploratory_replay_cutoff){
      cat('Exploratory replays can stop at depth:', depth, 'for seed', true_seed, '\n') 
      if(depth != min(depth_vec)){
        df[true_seed_mask & learning_mask & df$depth < depth,]$is_necessary_exploratory_replay = F 
      }
      break
    }
  }
}

# Normalize based on first learning depth
df$first_learning_depth = NA
for(true_seed in unique(df$true_seed)){
  true_seed_mask = df$true_seed == true_seed
  learning_depth = max(df[true_seed_mask,]$depth)
  df[true_seed_mask,]$first_learning_depth = learning_depth
}
df$depth_frac = df$depth / df$first_learning_depth

filename = paste0(data_dir, 'exploratory_replay_data_analyzed.csv')
write.csv(df, filename)
