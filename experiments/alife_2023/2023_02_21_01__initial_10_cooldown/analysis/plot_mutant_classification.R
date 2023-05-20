rm(list = ls())

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

seed = 28
depth = 375 

input_filename = paste0('../data/reps/', seed, '/mutants/', depth, '/combined_mutation_classification.csv')
plot_dir = paste0('../plots/reps/', seed, '/mutants/', depth)

if(!dir.exists(plot_dir)){
  mutant_dir = paste0('../plots/reps/', seed, '/mutants/')
  if(!(dir.exists(mutant_dir))){
    dir.create(mutant_dir)
  }
  dir.create(plot_dir)
}

df = read.csv(input_filename)
df$frac = df$count / sum(df$count)

text_offset = max(df$frac) * 0.05

# Plot number of replicates classified as each category
ggplot(df, aes(x = seed_classification_factor, y = frac, fill = seed_classification_factor)) + 
  geom_col() + 
  geom_text(aes(y = frac + text_offset, label = round(frac, 4))) + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Fraction of mutants (up to two steps)') + 
  theme(legend.position = 'none')
ggsave(paste0(plot_dir, '/mutant_classification.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/mutant_classification.png'), width = 9, height = 6, units = 'in')
