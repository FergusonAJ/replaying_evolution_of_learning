rm(list = ls())

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
summary_filename = paste0(data_dir, 'targeted_replay_analysis_summary.csv')
df_summary = read.csv(summary_filename)

raw_dirs = list.dirs('../..', recursive = F)
dir_vec = raw_dirs[grep('2023', raw_dirs)]

df = NA
seed_offset = 0
for(dir_path in dir_vec){
  cat(dir_path, '\n')
  df_dir = NA
  for(seed in 1:500){
    true_seed = seed + seed_offset
    # Don't load lineages we didn't replay
    if(!true_seed %in% unique(df_summary$true)){
      next
    }
    filename = paste0(dir_path, '/data/reps/', seed, '/dominant_lineage_summary.csv')
    if(!file.exists(filename)){
      cat('File does not exist:', filename, '\n')
      next
    }
    df_seed = read.csv(filename)
    df_seed$dir = dir_path
    df_seed$true_seed = true_seed
    df_seed = df_seed[,setdiff(colnames(df_seed), 'did_repro_frac')]
    if(is.data.frame(df_dir)){
      df_dir = rbind(df_dir, df_seed)
    } else {
      df_dir = df_seed
    }
  }
  if(is.data.frame(df_dir)){
    # Remove columns that were added part way through
    df_dir = df_dir[,setdiff(colnames(df_dir), 'did_repro_frac')]
    if(is.data.frame(df)){
      df = rbind(df, df_dir)
    } else {
      df = df_dir
    }
  }
  seed_offset = seed_offset + 500
}

output_filename = '../data/combined_lineage_data.csv'
write.csv(df, output_filename)
