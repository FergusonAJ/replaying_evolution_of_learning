rm(list = ls())

library(ggplot2)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")
source('./mutation_edit_distance.R')

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'targeted_replay_data_analyzed.csv')
df_replays = read.csv(base_data_filename)

df = data.frame(data = matrix(nrow = 0, ncol = 4))
colnames(df) = c('true_seed', 'prev_genome', 'focal_genome', 'num_muts')

dir_map = c(
  '0' = '../../2023_05_22_01__seeds_0_500', 
  '1' = '../../2023_05_22_02__seeds_500_1000',
  '2' = '../../2023_05_23_01__seeds_1000_1499',
  '3' = '../../2023_05_24_01__seeds_1500_1999',
  '4' = '../../2023_05_24_02__seeds_2000_2499', 
  '5' = '../../2023_05_25_01__seeds_2000_2499', 
  '6' = '../../2023_05_26_01__seeds_2500_2999', 
  '7' = '../../2023_05_26_02__seeds_3000_3499'
)

for(true_seed in unique(df_replays$true_seed)){
  seed = true_seed %% 500
  batch_id = as.character(floor(true_seed / 500))
  cat('true seed:', true_seed, '\n')
  focal_depth = df_replays[df_replays$is_largest_potentiation_gain & df_replays$true_seed == true_seed,]$depth - 1
  cat('  focal_depth:', focal_depth, '\n')
  max_potentiation_gain = df_replays[df_replays$is_largest_potentiation_gain & df_replays$true_seed == true_seed,]$target_window_potentiation_diff
  df_raw_lineage = read.csv(paste0(dir_map[batch_id], '/data/reps/', seed, '/dominant_lineage.csv'))
  str_a = df_raw_lineage[df_raw_lineage$depth == focal_depth,]$genome
  str_b = df_raw_lineage[df_raw_lineage$depth == focal_depth + 1,]$genome
  res = get_edit_distance(str_a, str_b)
  num_muts = res[nrow(res), ncol(res)]
  cat(num_muts, '\n')
  df[nrow(df) + 1,] = c(true_seed, str_a, str_b, num_muts)
}

ggplot(df, aes(x = num_muts)) + 
  geom_bar()
