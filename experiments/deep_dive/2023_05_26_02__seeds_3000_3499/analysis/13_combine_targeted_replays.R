rm(list = ls())

# Local include
source('./local_setup.R')

# Load data
df_all_classification = load_target_window_replay_classification_summary()

df = NA

# Loop through each seed
seeds_to_process = get_seeds_to_process()
seed = seeds_to_process[1]
for(seed in seeds_to_process){
  # Load each exploratory replay
  target_window_start = df_all_classification[df_all_classification$seed == seed & df_all_classification$is_target_window_start,]$depth
  target_window_end = df_all_classification[df_all_classification$seed == seed & df_all_classification$is_target_window_end,]$depth
  # Grab just those entries, remove data we don't have for target replays yet
  df_target_window_ends = df_all_classification[df_all_classification$seed == seed & (df_all_classification$is_target_window_start | df_all_classification$is_target_window_end),]
  df_target_window_ends = df_target_window_ends[,setdiff(colnames(df_target_window_ends), c('frac_diff', 'next_frac_diff'))] 
  df_target_window_ends$target_window_depth = df_target_window_ends$depth - target_window_start
  expected_targeted_replay_depths = seq(target_window_start + 1, target_window_end - 1)
  depth = expected_targeted_replay_depths[1]
  for(depth in expected_targeted_replay_depths){
    df_depth_classification_summary = try_load_replay_depth_classification_summary(seed, depth)
    if(!is.data.frame(df_depth_classification_summary)){
      cat('Could not find file for seed', seed, 'depth', depth, '. Skipping. \n')
      next
    }
    df_depth_classification_summary$seed = seed
    df_depth_classification_summary$target_window_depth = df_depth_classification_summary$depth - target_window_start
    df_depth_classification_summary$is_target_window_start = F
    df_depth_classification_summary$is_target_window_end = F
    if(is.data.frame(df)){
      df = rbind(df, df_depth_classification_summary)
    } else {
      df = df_depth_classification_summary
    }
  }
  df = rbind(df, df_target_window_ends)
}
processed_filename = get_targeted_replay_classification_summary_filename()
write.csv(df, processed_filename, row.names = F)
