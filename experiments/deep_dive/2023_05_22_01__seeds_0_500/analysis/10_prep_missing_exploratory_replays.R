# Local include
source('./local_setup.R')

df_summary = load_processed_summary_after_lineage_analysis()
df_replay_classification_summary = load_exploratory_replay_classification_summary()

replay_learning_mask = df_replay_classification_summary$is_learning

slurm_replay_seed_str = 'REPLAY_SEEDS="'
slurm_replay_depth_str = ''
affected_seeds = c()

# Loop through each seed
seeds_to_process = get_seeds_to_process()
seeds_to_extend = c()
seed = seeds_to_process[1]
for(seed in seeds_to_process){
  replay_seed_mask = df_replay_classification_summary$seed == seed
  missing_depths = c()
  first_learning_depth = df_summary[df_summary$seed == seed,]$first_learning_depth
  min_depth = min(df_replay_classification_summary[replay_seed_mask & replay_learning_mask,]$depth)
  max_relative_diff = first_learning_depth - min_depth
  for(relative_diff in seq(0, max_relative_diff, 50)){
    depth = first_learning_depth - relative_diff
    df_depth = try_load_replay_depth_classification_summary(seed, depth) 
    if(!is.data.frame(df_depth)){
      missing_depths = c(missing_depths, depth) 
    } else {
      if(nrow(df_depth) == 0){
        missing_depths = c(missing_depths, depth) 
      }      
    }
  } 
  if(length(missing_depths) == 0){
    cat('Seed', seed, 'is not missing any depths!\n')
  } else {
    affected_seeds = c(affected_seeds, seed)
    # Add onto the seed list
    if(length(affected_seeds) != 1){ # Not the first seed
      slurm_replay_seed_str = paste0(slurm_replay_seed_str, ' ')
    }
    slurm_replay_seed_str = paste0(slurm_replay_seed_str, seed)
    # Add entry to depth map 
    slurm_replay_depth_str = paste0(slurm_replay_depth_str, 'DEPTH_MAP[', seed, ']="')
    for(depth in sort(missing_depths)){
      if(depth != min(missing_depths)){
        slurm_replay_depth_str = paste0(slurm_replay_depth_str, ' ')
      }
      slurm_replay_depth_str = paste0(slurm_replay_depth_str, depth)
    }
    slurm_replay_depth_str = paste0(slurm_replay_depth_str, '"\n')
  }
}

slurm_replay_str = paste0(slurm_replay_seed_str, '"\ndeclare -a DEPTH_MAP\n', slurm_replay_depth_str)
cat('\n\n')
cat(slurm_replay_str)
