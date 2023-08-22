rm(list = ls())

library(ggplot2)
library(dplyr)

# Local include
source('../../2023_05_27_01__seeds_3500_3599/analysis/local_setup.R')

# Plot!
if(plot_dir == '../plots/'){
  plot_dir = paste0(plot_dir, 'initial_replicates/')
}
create_dir_if_needed(plot_dir)

raw_dirs = list.dirs('../..', recursive = F)
dir_vec = raw_dirs[grep('2023', raw_dirs)]

df = NA
for(dir_path in dir_vec){
  if(dir_path == '../../2023_05_27_01__seeds_3500_3599'){ # Skip the batch that wasn't actually needed
    next
  }
  filename = paste0(dir_path, '/data/processed_data/processed_classification.csv')
  if(!file.exists(filename)){
    cat('File does not exist:', filename, '\n')
    next
  }
  df_dir = read.csv(filename)
  cat(dir_path, sum(df_dir$count), '\n')
  df_dir$dir = dir_path
  if(is.data.frame(df)){
    df = rbind(df, df_dir)
  } else {
    df = df_dir
  }
}

# Reorder the classification labels
df$seed_classification_factor = factor(df$seed_classification, levels = c(
  seed_class_learning, 
  seed_class_bet_hedged_learning, 
  seed_class_bet_hedged_mixed, 
  seed_class_error_correction, 
  seed_class_bet_hedged_error_correction, 
  seed_class_small))

df_summary = df %>% 
  dplyr::group_by(seed_classification_factor, seed_classification) %>%
  dplyr::summarize(count = sum(count))


df_summary$frac = df_summary$count / sum(df_summary$count)

# Plot number of replicates classified as each category
ggplot(df_summary, aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) +
  geom_col() +
  geom_text(aes(y = count + 250, label = count), size = 4) +
  geom_text(aes(y = count + 100, label = round(frac, 2)), size = 4) +
  scale_fill_manual(values = color_map) +
  xlab('Classification') +
  ylab('Number of replicates') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=25, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14))
ggsave(paste0(plot_dir, '/final_dom_classification.pdf'), width = 8, height = 5, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_classification.png'), width = 8, height = 5, units = 'in')

# Plot number of replicates classified as each category as a fraction of all runs
ggplot(df_summary, aes(x = seed_classification_factor, y = frac, fill = seed_classification_factor)) +
  geom_col() +
  geom_text(aes(y = frac + 0.03, label = round(frac, 2)), size = 4) +
  scale_fill_manual(values = color_map) +
  xlab('Classification') +
  ylab('Fraction of replicates') +
  theme(legend.position = 'none') +
  theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1)) +
  theme(axis.text = element_text(size = 12)) +
  theme(axis.title = element_text(size = 14))
ggsave(paste0(plot_dir, '/final_dom_classification_frac.pdf'), width = 5, height = 5, units = 'in')
ggsave(paste0(plot_dir, '/final_dom_classification_frac.png'), width = 5, height = 5, units = 'in')


