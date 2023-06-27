rm(list = ls())

# Local include
source('./local_setup.R')

df_summary = load_processed_summary_after_lineage_analysis()
df_replay_classification_summary = load_exploratory_replay_classification_summary()

replay_learning_mask = df_replay_classification_summary$is_learning

# Loop through each seed
seeds_to_process = get_seeds_to_process()
seeds_to_extend = c()
seed = seeds_to_process[1]
for(seed in seeds_to_process){
  replay_seed_mask = df_replay_classification_summary$seed == seed
  min_depth = min(df_replay_classification_summary[replay_seed_mask & replay_learning_mask,]$depth)
  depth_vec = sort(df_replay_classification_summary[replay_seed_mask & replay_learning_mask,]$depth, decreasing = T)
  threshold_reached = F
  max_threshold_depth = NA
  depth = depth_vec[1]
  for(depth in depth_vec){
    if(df_replay_classification_summary[replay_learning_mask & replay_seed_mask & df_replay_classification_summary$depth == depth,]$frac <= exploratory_replay_cutoff){
      threshold_reached = T 
      max_threshold_depth = depth
      cat('Seed', seed, 'reached threshold at depth', depth, '!\n')
      break
    }
  }  
  if(threshold_reached){
    df_summary[df_summary$seed == seed,]$all_exploratory_replays_conducted = T
    df_summary[df_summary$seed == seed,]$first_exploratory_replay = max_threshold_depth
  } else {
    df_summary[df_summary$seed == seed,]$all_exploratory_replays_conducted = F
    seeds_to_extend = c(seeds_to_extend, seed)
  }
}
cat('\n')

if(length(seeds_to_extend) == 0){
  cat('All seeds finished! Exiting.\n\n')
  q()
}

cat('Extending seeds:', seeds_to_extend, '\n\n')

slurm_replay_str = 'REPLAY_SEEDS="'
for(seed in seeds_to_extend){
  if(seed != seeds_to_extend[1]){
    slurm_replay_str = paste0(slurm_replay_str, ' ')
  }
  slurm_replay_str = paste0(slurm_replay_str, seed)
}
slurm_replay_str = paste0(slurm_replay_str, '"\ndeclare -a DEPTH_MAP\n')
for(seed in seeds_to_extend){
  slurm_replay_str = paste0(slurm_replay_str, 'DEPTH_MAP[', seed, ']="')
  min_step = -1 * min(df_replay_classification_summary[df_replay_classification_summary$seed == seed,]$relative_depth) + 50 # Don't duplicate effort
  max_step = min_step + 250
  step_size = 50
  first_learning_depth = df_summary[df_summary$seed == seed,]$first_learning_depth
  for(step in seq(min_step, max_step, step_size)){
    if(first_learning_depth > step){
      slurm_replay_str = paste0(slurm_replay_str, first_learning_depth - step)
      if(step != max_step){
        slurm_replay_str = paste0(slurm_replay_str, ' ')
      }
    }
  }
  
  slurm_replay_str = paste0(slurm_replay_str, '"\n')
}
cat(slurm_replay_str)
