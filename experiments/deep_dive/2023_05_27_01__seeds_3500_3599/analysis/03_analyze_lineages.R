rm(list = ls())

library(ggplot2)

# Local include
source('./local_setup.R')

# Figure out which seeds to process
df_summary = load_processed_summary()
seeds_to_process = get_seeds_to_process()

# Create columns in summary data
if(!('first_learning_depth' %in% colnames(df_summary))){
  df_summary$first_learning_depth = NA
}
if(!('first_learning_origin_update' %in% colnames(df_summary))){
  df_summary$first_learning_origin_update = NA
}
if(!('first_learning_frac' %in% colnames(df_summary))){
  df_summary$first_learning_frac = NA
}
if(!('focal_window_start' %in% colnames(df_summary))){
  df_summary$focal_window_start = NA
}
if(!('focal_window_end' %in% colnames(df_summary))){
  df_summary$focal_window_end = NA
}
if(!('all_exploratory_replays_conducted' %in% colnames(df_summary))){
  df_summary$all_exploratory_replays_conducted = NA
}
if(!('first_exploratory_replay' %in% colnames(df_summary))){
  df_summary$first_exploratory_replay = NA
}

for(seed in seeds_to_process){
  summary_seed_mask = df_summary$seed == seed
  # Load all needed files and ensure they aren't empty
  { 
    # Main lineage summary
    lineage_filename = paste0('../data/reps/', seed, '/dominant_lineage_summary.csv') 
    df_lineage = try_load_file(lineage_filename)
    if(!is.data.frame(df_lineage)){
      next
    }
    if(nrow(df_lineage) <= 1){
      print(paste0('File is empty or corrupted: ', lineage_filename))
      next
    }
    # Raw lineage data
    raw_lineage_filename = paste0('../data/reps/', seed, '/dominant_lineage.csv') 
    df_raw_lineage = try_load_file(raw_lineage_filename)
    if(!is.data.frame(df_raw_lineage)){
      next
    }
    if(nrow(df_raw_lineage) <= 1){
      print(paste0('File is empty or corrupted: ', raw_lineage_filename))
      next
    }
    ## Population average data
    #fitness_filename = paste0('../data/reps/', seed, '/fitness.csv') 
    #df_fitness = try_load_file(fitness_filename)
    #if(!is.data.frame(df_fitness)){
    #  next
    #}
    #if(nrow(df_fitness) <= 1){
    #  print(paste0('File is empty or corrupted: ', fitness_filename))
    #  next
    #}
    ## Population max data
    #max_org_filename = paste0('../data/reps/', seed, '/max_org.csv') 
    #df_max_org = try_load_file(max_org_filename)
    #if(!is.data.frame(df_max_org)){
    #  next
    #}
    #if(nrow(df_max_org) <= 1){
    #  print(paste0('File is empty or corrupted: ', max_org_filename))
    #  next
    #}
  }
  
  # Update classification name
  if(sum(df_lineage$seed_classification == 'Bet-hedged imprinting')){
    df_lineage[df_lineage$seed_classification == 'Bet-hedged imprinting',]$seed_classification_factor = seed_class_bet_hedged_learning
    df_lineage[df_lineage$seed_classification == 'Bet-hedged imprinting',]$seed_classification = seed_class_bet_hedged_learning
  }
 
  # Find depth where learning first appeared 
  first_learning_depth = min(df_lineage[df_lineage$seed_classification == seed_class_learning,]$depth)
  cat('Learning first evolved at depth: ', first_learning_depth, '\n')
  # Figure out the update (not depth) learning first evolved 
  first_learning_origin_update = df_raw_lineage[df_raw_lineage$depth == first_learning_depth,]$origin_time
  first_learning_frac = round(first_learning_origin_update / 250000, 2)
  cat('Origin update of first learning genotype: ', first_learning_origin_update, ' (', first_learning_frac, ')\n')
  
  # Record first depth learning appeared in summary data
  df_summary[summary_seed_mask,]$first_learning_depth = first_learning_depth
  df_summary[summary_seed_mask,]$first_learning_origin_update = first_learning_origin_update
  df_summary[summary_seed_mask,]$first_learning_frac = first_learning_frac
 
  # Add origin time to full lineage data 
  get_origin_time = function(v, df_raw_lineage){
    depth = as.numeric(v['depth'])
    df_tmp = df_raw_lineage[df_raw_lineage$depth == depth,]
    if(nrow(df_tmp) == 0){
      return(0.01)
    }
    return(as.numeric(df_tmp[1,]$origin_time))
  }
  df_lineage$origin_time = apply(df_lineage, 1, get_origin_time, df_raw_lineage)

  processed_lineage_dir = paste0(processed_data_dir, '/reps/', seed)  
  if(!dir.exists(processed_lineage_dir)){ dir.create(processed_lineage_dir, recursive = T) }
  processed_lineage_filename = paste0(processed_lineage_dir, '/processed_lineage.csv')  
  write.csv(df_lineage, processed_lineage_filename, row.names = F)
}
df_summary$process_annotations = 'a00,03'
write.csv(df_summary, paste0(processed_data_dir, 'processed_summary_after_lineage_analysis.csv'), row.names = F)
