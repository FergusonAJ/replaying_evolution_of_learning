rm(list = ls())

library(ggplot2)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')

seeds_that_contain_learning = c()
seeds_that_end_in_learning = c()
max_depth_vec = c()
max_depth_vec_learning = c()
reps_dir = '../data/reps/'
#reps_dir = '../../../exploration/2023_01_26_04__oft_cooldown_step_4/data/reps/'

for(seed in c(1:200)){
  input_filename = paste0(reps_dir, seed, '/dominant_lineage_summary.csv') 
  if(!file.exists(input_filename)){
    print(paste0('File does not exist: ', input_filename))
    next 
  }
  df = read.csv(input_filename)
  if(seed_class_learning %in% unique(df$seed_classification)){
    seeds_that_contain_learning = c(seeds_that_contain_learning, seed)
  }
  max_depth = max(df$depth)
  cat(seed, ' ', max_depth, '\n')
  max_depth_vec = c(max_depth_vec, max_depth)
  final_seed_class = df[df$depth == max_depth,]$seed_classification
  if(final_seed_class == seed_class_learning){
    seeds_that_end_in_learning = c(seeds_that_end_in_learning, seed)
    max_depth_vec_learning = c(max_depth_vec_learning, max_depth)
  }
  
}

cat('Seeds that contain learning:\n')
print(seeds_that_contain_learning)
cat('Seeds that end in learning:\n')
print(seeds_that_end_in_learning)
cat('Seeds that contain learning but lose it:\n')
print(setdiff(seeds_that_contain_learning, seeds_that_end_in_learning))

cat('All max depths:\n')
print(max_depth_vec)
cat('Mean: ', mean(max_depth_vec), '; SD: ', sd(max_depth_vec))

cat('Learning max depths:\n')
print(max_depth_vec_learning)
cat('Mean: ', mean(max_depth_vec_learning), '; SD: ', sd(max_depth_vec_learning))
