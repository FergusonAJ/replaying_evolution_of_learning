rm(list = ls())

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

seed = 28
depth = 392

input_filename = paste0('../data/reps/', seed, '/mutants/', depth, '/combined_learning_summary.csv')
plot_dir = paste0('../plots/reps/', seed, '/mutants/', depth)

if(!dir.exists(plot_dir)){
  mutant_dir = paste0('../plots/reps/', seed, '/mutants/')
  if(!(dir.exists(mutant_dir))){
    dir.create(mutant_dir)
  }
  dir.create(plot_dir)
}

df = read.csv(input_filename)

# Plot number of replicates classified as each category
ggplot(df, aes(x = merit_mean)) + 
  geom_histogram() + 
  xlab('Mean merit') +
  geom_vline(aes(xintercept=89443.33)) +
  scale_x_continuous(trans = 'log2')
ggsave(paste0(plot_dir, '/learning_mut_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/learning_mut_merit.png'), width = 9, height = 6, units = 'in')

df['x-1' %in% df$seed,]
