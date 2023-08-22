# Local include
source('./local_setup.R')

# Load data
df_all_classification = load_target_window_replay_classification_summary()

# Config options
replay_step = 50

seed_vec = sort(unique(df_all_classification$seed))
seed = seed_vec[1]
for(seed in seed_vec){
  base_rep_dir = paste0(data_dir, '/reps/', seed)
  replay_base_dir = paste0(base_rep_dir, '/full_replays')
  df_lineage = load_processed_lineage(seed)
  first_learning_depth = min(df_lineage[df_lineage$seed_classification == seed_class_learning,]$depth)
  rep_process_dir = paste0(processed_data_dir, '/reps/', seed)
 
  target_window_start = df_all_classification[df_all_classification$seed == seed & df_all_classification$is_target_window_start,]$depth
  target_window_end = df_all_classification[df_all_classification$seed == seed & df_all_classification$is_target_window_end,]$depth
  depth = target_window_start + 1
  for(depth in seq(target_window_start + 1, target_window_end - 1)){
    cat(depth, '\n')
    replay_depth_dir = paste0(replay_base_dir, '/', depth)
    replay_depth_filename = paste0(replay_depth_dir, '/combined_final_dominant_data.csv')
    df_replay_depth = load_file(replay_depth_filename) 
    if(nrow(df_replay_depth) <= 1){
      cat('  File empty\n')
      next
    }
    
    # Process depth
    df_replay_depth = classify_individual_trials(df_replay_depth)
    df_replay_depth = classify_seeds(df_replay_depth)
    df_replay_depth_summary = summarize_final_dominant_org_data(df_replay_depth)
    replay_depth_classification_summary = summarize_classifications(df_replay_depth_summary)
    
    # Add depth column
    df_replay_depth$depth = depth
    df_replay_depth_summary$depth = depth
    replay_depth_classification_summary$depth = depth
    
    # Calculate the fraction of each behavior at each depth, 
    #   adding zeros for non-existent behaviors
    replay_depth_classification_summary$frac = 0
    for(classification_string in seed_classifcation_order_vec){
      if(!(classification_string %in% replay_depth_classification_summary$seed_classification)){
        replay_depth_classification_summary[nrow(replay_depth_classification_summary) + 1,] = list(classification_string, 0, NA, NA, classification_string, depth, 0)
      }
      mask = replay_depth_classification_summary$seed_classification == classification_string
      replay_depth_classification_summary[mask,]$frac = 
        replay_depth_classification_summary[mask,]$count / sum(replay_depth_classification_summary$count)
    }
    
    # Grab the lineage behavior at each depth
    lineage_classification = df_lineage[df_lineage$depth == depth,]$seed_classification
    df_replay_depth$lineage_classification = lineage_classification 
    df_replay_depth_summary$lineage_classification = lineage_classification
    replay_depth_classification_summary$lineage_classification = lineage_classification
    lineage_merit_mean = df_lineage[df_lineage$depth == depth,]$merit_mean
    df_replay_depth$lineage_merit_mean = lineage_merit_mean 
    df_replay_depth_summary$lineage_merit_mean = lineage_merit_mean
    replay_depth_classification_summary$lineage_merit_mean = lineage_merit_mean
    
    # Add column for if this entry is looking at learning
    df_replay_depth$is_learning = df_replay_depth$seed_classification == seed_class_learning
    df_replay_depth_summary$is_learning = df_replay_depth_summary$seed_classification == seed_class_learning
    replay_depth_classification_summary$is_learning = replay_depth_classification_summary$seed_classification == seed_class_learning
    
    # Add column for relative depth to first appearance of learning
    df_replay_depth$relative_depth = df_replay_depth$depth - first_learning_depth
    df_replay_depth_summary$relative_depth = df_replay_depth_summary$depth - first_learning_depth
    replay_depth_classification_summary$relative_depth = replay_depth_classification_summary$depth - first_learning_depth
    
    # Add column for if this entry is an exploratory replay
    df_replay_depth$is_exploratory_replay = df_replay_depth$relative_depth %% 50 == 0
    df_replay_depth_summary$is_exploratory_replay = df_replay_depth_summary$relative_depth %% 50 == 0
    replay_depth_classification_summary$is_exploratory_replay = replay_depth_classification_summary$relative_depth %% 50 == 0
   
    # Save all new data to file 
    depth_process_data_dir = paste0(rep_process_dir, '/depths/', depth)
    create_dir_if_needed(depth_process_data_dir)
    write.csv(df_replay_depth, paste0(depth_process_data_dir, '/processed_data.csv'), row.names = F)
    write.csv(df_replay_depth_summary, paste0(depth_process_data_dir, '/processed_summary.csv'), row.names = F)
    write.csv(replay_depth_classification_summary, paste0(depth_process_data_dir, '/processed_classification.csv'), row.names = F)
  }
}
