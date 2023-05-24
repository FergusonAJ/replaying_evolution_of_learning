rm(list = ls())

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

seed = 28
depth_vec = c(375, 391:394, 413)
#depth_vec = 391:394
input_dir = paste0('../data/reps/', seed, '/mutants/')
plot_dir = paste0('../plots/reps/', seed, '/mutants/')

merit_mean_375 = 653.9441
merit_mean_391 = 136430.3
merit_mean_392 = 89443.33
merit_mean_393 = 16002405700
merit_mean_394 = 20114930800
merit_mean_413 = 690410377000 
df_merit = data.frame(data = matrix(nrow = 0, ncol = 3))
colnames(df_merit) = c('depth', 'merit_mean', 'seed_classification')
df_merit[nrow(df_merit) + 1,] = c(375, merit_mean_375, 'Bet-hedged imprinting')
df_merit[nrow(df_merit) + 1,] = c(391, merit_mean_391, 'Bet-hedged imprinting')
df_merit[nrow(df_merit) + 1,] = c(392, merit_mean_392, 'Bet-hedged imprinting')
df_merit[nrow(df_merit) + 1,] = c(393, merit_mean_393, 'Learning')
df_merit[nrow(df_merit) + 1,] = c(394, merit_mean_394, 'Learning')
df_merit[nrow(df_merit) + 1,] = c(413, merit_mean_413, 'Learning')
df_merit$depth = as.numeric(df_merit$depth)
df_merit$merit_mean = as.numeric(df_merit$merit_mean)


df = NA
for(depth in depth_vec){
  input_filename = paste0(input_dir, '/', depth, '/one_step_learning_muts.csv')
  df_tmp = read.csv(input_filename)
  df_tmp$depth = depth
  if('X.2' %in% colnames(df_tmp)){
    df_tmp = df_tmp[,setdiff(colnames(df_tmp), c('X.2'))]
  }
  if(is.data.frame(df)){
    df = rbind(df, df_tmp)
  } else{
    df = df_tmp
  }
}
# Convert seed into usable mut_seed
A = regexpr('x', df$seed, perl=T)
df$mut_seed = as.numeric(substring(df$seed, 1, A-1))


if(!dir.exists(plot_dir)){
  dir.create(plot_dir, recursive = T)
}

local_color_map = c(
  color_map['Learning'],
  color_map['Bet-hedged imprinting']
)

# Plot number of replicates classified as each category
ggplot(df) + 
  geom_histogram(mapping = aes(x = merit_mean), bins=50) + 
  xlab('Mean merit') +
  geom_vline(df_merit, mapping = aes(xintercept=merit_mean, color = seed_classification)) +
  facet_grid(rows = vars(depth), scales = 'free_y') +
  theme(legend.position = 'bottom') +
  scale_color_manual(values = local_color_map) +
  scale_x_continuous(trans = 'log2')#, breaks = c(1, 2^10, 2^20, 2^30, 2^40), limits = c(2, 2^40)) 
ggsave(paste0(plot_dir, '/one_step_learning_mut_merit.pdf'), width = 9, height = 9, units = 'in')
ggsave(paste0(plot_dir, '/one_step_learning_mut_merit.png'), width = 9, height = 9, units = 'in')
