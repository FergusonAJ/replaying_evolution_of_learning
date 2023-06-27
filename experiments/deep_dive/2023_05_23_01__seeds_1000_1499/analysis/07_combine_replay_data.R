rm(list = ls())

# Local include
source('./local_setup.R')

df = NA

# Loop through each seed
seeds_to_process = get_seeds_to_process()
seed = seeds_to_process[1]
for(seed in seeds_to_process){
  # Load each exploratory replay
  existing_exploratory_replay_depths = get_exploratory_replay_depths(seed)
  depth = existing_exploratory_replay_depths[1]
  for(depth in existing_exploratory_replay_depths){
    df_depth_classification_summary = try_load_replay_depth_classification_summary(seed, depth)
    if(!is.data.frame(df_depth_classification_summary)){
      cat('Could not find file for seed', seed, 'depth', depth, '. Skipping. \n')
      next
    }
    df_depth_classification_summary$seed = seed
    if(is.data.frame(df)){
      df = rbind(df, df_depth_classification_summary)
    } else {
      df = df_depth_classification_summary
    }
  }
}
processed_filename = paste0(processed_data_dir, '/processed_exploratory_replay_classification_summary.csv')
write.csv(df, processed_filename, row.names = F)
