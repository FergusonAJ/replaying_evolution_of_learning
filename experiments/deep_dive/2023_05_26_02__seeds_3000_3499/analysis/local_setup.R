# Load global files
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')
#source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# User defined variables
plot_dir = '../plots/'
data_dir = '../data/'
process_learning_seeds = T
process_all_seeds = F
exploratory_replay_cutoff = 0.2

# Ensure directory structure is okay
if(!dir.exists(data_dir)){
  cat('Error! Data directory does not exist: ', data_dir, '\n')
  cat('Exiting.\n')
  quit(status = 1)
}
if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T, showWarnings = F)
processed_data_dir = paste0(data_dir, '/processed_data/') 
if(!dir.exists(processed_data_dir)) dir.create(processed_data_dir, recursive = T, showWarnings = F)

# Helper functions for file IO
load_file = function(filename){
 if(!file.exists(filename)){
   cat('Error! Cannot find file: ', filename, '\n')
   cat('Exiting!\n')
   q()
 }
 return(read.csv(filename))
}
try_load_file = function(filename){
 if(!file.exists(filename)){
   cat('Cannot find file: ', filename, '\n')
   return(F)
 }
 return(read.csv(filename))
}
create_dir_if_needed = function(dir_name, recursive = T){
  if(!dir.exists(dir_name)){
    dir.create(dir_name, recursive = recursive)
  }
}
create_dirs_if_needed = function(dir_names, recursive = T){
  for(dir_name in dir_names){
    create_dir_if_needed(dir_name, recursive)
  }
}

# Helper functions for specific filenames
get_processed_data_filename = function(){
  filename =  paste0(processed_data_dir, '/processed_full.csv')
  return(filename)
}
get_processed_summary_filename = function(){
  filename =  paste0(processed_data_dir, '/processed_summary.csv')
  return(filename)
}
get_processed_summary_after_lineage_analysis_filename = function(){
  filename =  paste0(processed_data_dir, '/processed_summary_after_lineage_analysis.csv')
  return(filename)
}
get_processed_classification_filename = function(){
  filename =  paste0(processed_data_dir, '/processed_classification.csv')
  return(filename)
}
get_processed_lineage_filename = function(seed){
  filename =  paste0(processed_data_dir, '/reps/', seed, '/processed_lineage.csv')
  return(filename)
}
get_replay_depth_classification_summary_filename = function(seed, depth){
  filename = paste0(processed_data_dir, '/reps/', seed, '/depths/', depth, '/processed_classification.csv')
  return(filename)
}
get_exploratory_replay_classification_summary_filename = function(){
  filename = paste0(processed_data_dir, '/processed_exploratory_replay_classification_summary.csv')
  return(filename)
}
get_target_window_replay_classification_summary_filename = function(){
  filename = paste0(processed_data_dir, '/processed_target_window_classification_summary.csv')
  return(filename)
}
get_targeted_replay_classification_summary_filename = function(){
  filename = paste0(processed_data_dir, '/processed_targeted_replay_classification_summary.csv')
  return(filename)
}

# Helper functions for loading processed data
load_processed_data = function(){
  filename =  get_processed_data_filename()
  return(load_file(filename))
}
load_processed_summary = function(){
  filename = get_processed_summary_filename()
  return(load_file(filename))
}
load_processed_summary_after_lineage_analysis = function(){
  filename = get_processed_summary_after_lineage_analysis_filename()
  return(load_file(filename))
}
load_processed_classification = function(){
  filename = get_processed_classification_filename()
  return(load_file(filename))
}
load_processed_lineage = function(seed){
  filename = get_processed_lineage_filename(seed)
  return(load_file(filename))
}
load_replay_depth_classification_summary = function(seed, depth){
  filename = get_replay_depth_classification_summary_filename() 
  return(load_file(filename))
}
try_load_replay_depth_classification_summary = function(seed, depth){
  filename = get_replay_depth_classification_summary_filename(seed, depth)
  return(try_load_file(filename))
}
load_exploratory_replay_classification_summary = function(){
  filename = get_exploratory_replay_classification_summary_filename()
  return(load_file(filename))
}
load_target_window_replay_classification_summary = function(){
  filename = get_target_window_replay_classification_summary_filename()
  return(load_file(filename))
}
load_targeted_replay_classification_summary = function(){
  filename = get_targeted_replay_classification_summary_filename()
  return(load_file(filename))
}

# Get summary annotations as a list
get_summary_annotations = function(){
  df_summary = load_processed_summary()
  if(!('process_annotations' %in% colnames(df_summary))){
   return(c()) 
  }
  unique_annotations = unique(df_summary$process_annotations)
  if(length(unique_annotations) != 1) {
    cat('Error! More than one annotation present in summary.\n')
    cat(unique_annotations, '\n')
    cat('Exiting.\n')
    q()
  }
  annotations = substring(unique_annotations[1], first = 3)
  return(strsplit(annotations, ',', fixed = T))
}

# Get the seeds of replays to process
get_seeds_to_process = function(){
  df_summary = load_processed_summary()
  # Figure out which seeds to process
  seeds_to_process = c()
  if(process_learning_seeds){
    return(sort(df_summary[df_summary$seed_classification == seed_class_learning,]$seed))
  }
  if(process_all_seeds){
    return(seeds_to_process = seq(1, max(df_summary$seed)))
  } 
  return(c())
}

# Get the exploratory replay depths of a given seed
get_exploratory_replay_depths = function(seed){
  base_rep_dir = paste0(data_dir, '/reps/', seed)
  replay_base_dir = paste0(base_rep_dir, '/full_replays')
  if(!dir.exists(replay_base_dir)){
    cat('Error! Directory does not exist: ', replay_base_dir, '\n')
    q()
  }
  depth_vec = list.files(replay_base_dir, '')
  # Grab only numeric directories
  depth_vec = depth_vec[grep('^\\d+$', depth_vec)]
  depth_vec = as.numeric(depth_vec)
  # Grab depth of first learning genotype
  df_summary = load_processed_summary_after_lineage_analysis()
  first_learning_depth = df_summary[df_summary$seed == seed,]$first_learning_depth
  # Return only exploratory replays (mod 50 from first learning depth)
  depth_vec = depth_vec[abs(first_learning_depth - depth_vec) %% 50 == 0]
  return(depth_vec)
}

get_expected_exploratory_replay_depths = function(seed, steps = 5){
  # Grab depth of first learning genotype
  df_summary = load_processed_summary_after_lineage_analysis()
  first_learning_depth = df_summary[df_summary$seed == seed,]$first_learning_depth
  expected_depths = c(first_learning_depth)
  for(dist in 50 * seq(1, steps - 1)){
    expected_depths = c(expected_depths, first_learning_depth - dist)
  }
  return(expected_depths)
}

