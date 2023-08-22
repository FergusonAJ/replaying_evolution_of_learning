rm(list = ls())

library(ggplot2)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Load data
base_data_filename = paste0(data_dir, 'targeted_replay_data_analyzed.csv')
df_replays = read.csv(base_data_filename)

df = data.frame(data = matrix(nrow = 0, ncol = 8))
colnames(df) = c('true_seed', 'smaller_frac', 'much_smaller_frac', 'larger_frac', 'much_larger_frac', 'potentiation_gain', 'frac_of_optimal_mut', 'diff_from_log_optimal_mut')

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
  cat('True seed:', true_seed, '\n')
  focal_depth = df_replays[df_replays$is_largest_potentiation_gain & df_replays$true_seed == true_seed,]$depth - 1
  cat('  focal_depth:', focal_depth, '\n')
  max_potentiation_gain = df_replays[df_replays$is_largest_potentiation_gain & df_replays$true_seed == true_seed,]$target_window_potentiation_diff
  df_lineage = read.csv(paste0(dir_map[batch_id], '/data/reps/', seed, '/dominant_lineage_summary.csv'))
  focal_merit_mean = df_lineage[df_lineage$depth == focal_depth + 1,]$merit_mean
  focal_repro_time_mean = df_lineage[df_lineage$depth == focal_depth + 1,]$repro_updates_mean
  focal_fitness = focal_merit_mean / focal_repro_time_mean
  
  df_mut = read.csv(paste0(dir_map[batch_id], '/data/reps/', seed, '/mutants/', focal_depth, '/one_step_mut_summary_1.csv'))
  if(nrow(df_mut) >= 20000)
  {
    cat('True seed:', true_seed, 'did not test all mutations (>20k)\n')
    next
  }
  df_mut$fitness_mean = df_mut$merit_mean / df_mut$repro_updates_mean
  
  df_mut$diff_class = 'Smaller'
  if(focal_merit_mean < max(df_mut$merit_mean)){
    df_mut[df_mut$merit_mean > focal_merit_mean,]$diff_class = 'Larger'
  }
  if(sum(df_mut$merit_mean > focal_merit_mean * 32)){
    df_mut[df_mut$merit_mean > focal_merit_mean * 32,]$diff_class = 'Much larger'
  }
  if(focal_merit_mean > min(df_mut$merit_mean)){
    df_mut[df_mut$merit_mean < focal_merit_mean * (1/32),]$diff_class = 'Much smaller'
  }
  
  df[nrow(df) + 1,] = c(
    true_seed,
    sum(df_mut$diff_class %in% c('Smaller', 'Much smaller')) / nrow(df_mut),
    sum(df_mut$diff_class == 'Much smaller') / nrow(df_mut),
    sum(df_mut$diff_class %in% c('Larger', 'Much larger')) / nrow(df_mut),
    sum(df_mut$diff_class == 'Much larger') / nrow(df_mut),
    max_potentiation_gain,
    focal_merit_mean / max(df_mut$merit_mean),
    log(focal_merit_mean,2) - log(max(df_mut$merit_mean),2)
  )
  
  
  ggplot(df_mut, aes(x = merit_mean)) + 
    geom_vline(xintercept = focal_merit_mean, linetype = 'dashed') +
    geom_histogram(bins = 100) + 
    scale_x_log10()
  
  ggplot(df_mut, aes(x = merit_mean, fill = as.factor(diff_class))) + 
    geom_vline(xintercept = focal_merit_mean, linetype = 'dashed') +
    geom_histogram(bins = 50) + 
    scale_x_log10()
  
  cat('  Frac larger:', sum(df_mut$diff_class %in% c('Larger', 'Much larger')) / nrow(df_mut), '\n')
  cat('  Frac much larger:', sum(df_mut$diff_class == 'Much larger') / nrow(df_mut), '\n')
}

ggplot(df, aes(x = smaller_frac, y = potentiation_gain)) +
  geom_point() + 
  scale_x_continuous(limits = c(0,1)) + 
  scale_y_continuous(limits = c(0,1)) + 
  xlab('Focal mutation merit percentile') + 
  ylab('Focal mutation potentiation gain')

df$frac_of_optimal_mut
ggplot(df, aes(x = frac_of_optimal_mut)) + 
  geom_histogram() + 
  scale_x_log10()

ggplot(df, aes(x = diff_from_log_optimal_mut)) + 
  geom_histogram()

ggplot(df, aes(x = diff_from_log_optimal_mut, y = smaller_frac)) + 
  geom_point() + 
  xlab('Optimal mutation score - focal score') + 
  ylab('Focal mutation merit percentile') + 
  scale_y_continuous(limits = c(0,1))

single_muts = c("221", "327", "346", "422", "476", "477", "508", "557", "641", "685", "805", "859", "1487", "1703", "1738", "2188", "2331", "2336", "2595", "2686", "2710", "2909", "3108", "3183", "3206", "3628", "3656", "3865", "3906", "3926")

ggplot(df[df$true_seed %in% single_muts,], aes(x = smaller_frac, y = potentiation_gain)) +
  geom_point() + 
  scale_x_continuous(limits = c(0,1)) + 
  scale_y_continuous(limits = c(0,1)) + 
  xlab('Focal mutation merit percentile') + 
  ylab('Focal mutation potentiation gain')
