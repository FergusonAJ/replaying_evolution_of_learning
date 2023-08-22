rm(list = ls())

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

raw_dirs = list.dirs('../..', recursive = F)
dir_vec = raw_dirs[grep('2023', raw_dirs)]

df = NA
seed_offset = 0
for(dir_path in dir_vec){
  if(dir_path == '../../2023_05_27_01__seeds_3500_3599'){ # Skip the batch that wasn't actually needed
    next
  }
  filename = paste0(dir_path, '/data/processed_data/processed_targeted_replay_classification_summary.csv')
  if(!file.exists(filename)){
    cat('File does not exist:', filename, '\n')
    next
  }
  df_dir = read.csv(filename)
  df_dir$dir = dir_path
  df_dir$true_seed = df_dir$seed + seed_offset
  true_seed = df_dir$true_seed[1]
  seed_offset = seed_offset + 500
  if(is.data.frame(df)){
    df = rbind(df, df_dir)
  } else {
    df = df_dir
  }
}

# Remove the 51st replicate -- we didn't run targeted replays for it
df = df[df$true_seed != 4219,]


create_dir_if_needed(data_dir)
base_data_filename = paste0(data_dir, 'targeted_replay_data_base.csv')
write.csv(df, base_data_filename)

