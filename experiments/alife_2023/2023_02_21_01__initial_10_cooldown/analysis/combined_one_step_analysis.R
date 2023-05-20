rm(list = ls())

library(ggplot2)

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

seed = 28
input_dir = paste0('../data/reps/', seed, '/mutants/')
plot_dir = paste0('../plots/reps/', seed, '/mutants/')

df = NA

for(depth in c(375, 391:394, 413)){
  input_filename = paste0(input_dir, '/', depth, '/combined_one_step_classification.csv')
  df_tmp = read.csv(input_filename)
  df_tmp$frac = df_tmp$count / sum(df_tmp$count)
  df_tmp$depth = depth
  if(!is.data.frame(df)){
    df = df_tmp
  } else {
    df = rbind(df, df_tmp) 
  }
}

# Plot fraction of mutants classified as each category
ggplot(df, aes(x = depth, y = frac, color = seed_classification_factor)) + 
  geom_vline(xintercept=392, linetype='dashed', alpha = 0.2) +
  geom_point(size=1.2) + 
  geom_line(size=1) + 
  scale_color_manual(values = color_map) + 
  xlab('Steps from ancestor') + 
  ylab('Fraction of one-step mutants') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/combined_one_step_classification.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/combined_one_step_classification.png'), width = 9, height = 6, units = 'in')

ggplot(df[df$depth >= 391 & df$depth <= 394,], aes(x = depth, y = frac, color = seed_classification_factor)) + 
  geom_vline(xintercept=392, linetype='dashed', alpha = 0.2) +
  geom_point(size=1.2) + 
  geom_line(size=1) + 
  scale_color_manual(values = color_map) + 
  xlab('Steps from ancestor') + 
  ylab('Fraction of one-step mutants') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/combined_one_step_classification__focal.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/combined_one_step_classification__focal.png'), width = 9, height = 6, units = 'in')
