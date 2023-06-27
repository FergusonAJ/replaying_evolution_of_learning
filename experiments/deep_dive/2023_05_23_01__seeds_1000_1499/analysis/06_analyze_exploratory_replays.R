rm(list = ls())

library(ggplot2)
library(dplyr)

# Local include
source('./local_setup.R')

# Load data
df_summary = load_processed_summary_after_lineage_analysis()

# Config variables
process_anyway = F # If true, will re-process existing data

# Loop through each seed
seeds_to_process = get_seeds_to_process()
seed = seeds_to_process[1]
for(seed in seeds_to_process){
  cat('Seed: ', seed, '\n')
  # Create variables to make directory access easier
  #   and create missing directories
  base_rep_dir = paste0(data_dir, '/reps/', seed)
  replay_base_dir = paste0(base_rep_dir, '/full_replays')
  rep_process_dir = paste0(processed_data_dir, '/reps/', seed)
  replay_process_dir = paste0(rep_process_dir, '/full_replays')
  plot_dir = paste0('../plots/reps/', seed, '/replays/')
  plot_dir_focal = paste0(plot_dir, '/focal')
  plot_dir_initial = paste0(plot_dir, '/initial')
  plot_dir_all = paste0(plot_dir, '/all')
  plot_dir_depths = paste0(plot_dir, '/depths')
  create_dirs_if_needed(c(plot_dir, plot_dir_focal, plot_dir_initial, 
                          plot_dir_all, plot_dir_depths,
                          rep_process_dir, replay_process_dir))
 
  # Load in lineage data
  df_lineage = load_processed_lineage(seed)

  # Find the depth at which learning first appeared
  first_learning_depth = df_summary[df_summary$seed == seed,]$first_learning_depth
  
  # Load in all replay data, categorize it, and save to disk 
  # Start with the initial data, from the initial parallel replicates
  df_replay = read.csv(paste0(data_dir, '/combined_final_dominant_data.csv'))
  df_replay$depth = 0
  
  # Get the depths of exploratory replays, actual and expected
  existing_exploratory_replay_depths = get_exploratory_replay_depths(seed)
  min_relative_diff = first_learning_depth - min(existing_exploratory_replay_depths)
  expected_steps = min(min_relative_diff / 50, 5)
  expected_exploratory_replay_depths = get_expected_exploratory_replay_depths(seed, expected_steps)
  cat('Missing exploratory replay depths:', 
      setdiff(expected_exploratory_replay_depths, existing_exploratory_replay_depths),
      '\n')
  
  # Load each exploratory replay
  depth = existing_exploratory_replay_depths[1]
  for(depth in existing_exploratory_replay_depths){
    cat('Processing depth:', depth, '\n')
    replay_depth_dir = paste0(replay_base_dir, '/', depth)
    depth_process_data_dir = paste0(rep_process_dir, '/depths/', depth)
    depth_data_filename = paste0(depth_process_data_dir, '/processed_data.csv')
    depth_summary_filename = paste0(depth_process_data_dir, '/processed_summary.csv')
    depth_classification_filename = paste0(depth_process_data_dir, '/processed_classification.csv')
    if(!process_anyway & 
       file.exists(depth_data_filename) & 
       file.exists(depth_summary_filename) & 
       file.exists(depth_classification_filename)){
      cat('  Already processed. Skipping.\n')
      next
    }
    
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
    create_dir_if_needed(depth_process_data_dir)
    write.csv(df_replay_depth, paste0(depth_process_data_dir, '/processed_data.csv'), row.names = F)
    write.csv(df_replay_depth_summary, paste0(depth_process_data_dir, '/processed_summary.csv'), row.names = F)
    write.csv(replay_depth_classification_summary, paste0(depth_process_data_dir, '/processed_classification.csv'), row.names = F)
  }
} # End seed for loop

