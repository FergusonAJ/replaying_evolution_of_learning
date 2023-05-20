rm(list = ls())

source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

library(ggplot2)

df_aggregate = data.frame(data = matrix(nrow = 0, ncol = 6))
colnames(df_aggregate) = c('seed', 'earliest_split', 'max_depth', 'earliest_split_frac', 'num_orgs_max', 'count_with_max_num_orgs')
df_aggregate$seed = as.numeric(df_aggregate$seed)
df_aggregate$earliest_split = as.numeric(df_aggregate$earliest_split)
df_aggregate$max_depth = as.numeric(df_aggregate$max_depth)
df_aggregate$earliest_split_frac = as.numeric(df_aggregate$earliest_split_frac)
df_aggregate$num_orgs_max = as.numeric(df_aggregate$num_orgs_max)
df_aggregate$count_with_max_num_orgs = as.numeric(df_aggregate$count_with_max_num_orgs)

for(seed in 1:200){
  data_dir = paste0('../data/reps/', seed,'/phylo')
  df = read.csv(paste0(data_dir, '/phylogeny_manual_250000.csv'))
  
  # Convert ancestor list for root org
  df[df$ancestor_list == '[NONE]',]$ancestor_list = '[-1]'
  
  df_extant = df[df$num_orgs > 0,]
  dominant_org = df[df$num_orgs == max(df$num_orgs),][1,]
  
  df$is_dominant_lineage = F
  id = dominant_org$id
  while(id != '-1'){
    df[df$id == id,]$is_dominant_lineage = T
    next_id = df[df$id == id,]$ancestor_list
    next_id = sub('\\[', '', next_id)
    next_id = sub('\\]', '', next_id)
    id = as.numeric(next_id)
  }
  
  min_split =  min(df[df$num_offspring > 1,]$depth)
  max_depth = max(df$depth)
  frac = min_split / max_depth
  num_orgs_max = max(df$num_orgs)
  count_with_max_num_orgs = sum(df$num_orgs == num_orgs_max)
  df_aggregate[nrow(df_aggregate) + 1,] = c(seed, min_split, max_depth, frac, num_orgs_max, count_with_max_num_orgs)
  
  output_filename = paste0(data_dir, '/phylogeny_converted.csv') 
  write.csv(df, output_filename, row.names = F)
  cat('Output saved to: ', output_filename, '\n')
}

df_rep_summary = read.csv('../data/processed_data/processed_summary.csv')
df_combined_phylo = read.csv('../data/combined_final_phylogenetic_data.csv')
df_aggregate$seed_classification = NA
df_combined_phylo$seed_classification = NA
for(seed in 1:200){
  df_aggregate[df_aggregate$seed == seed,]$seed_classification = df_rep_summary[df_rep_summary$seed == seed,]$seed_classification
  df_combined_phylo[df_combined_phylo$seed == seed,]$seed_classification = df_rep_summary[df_rep_summary$seed == seed,]$seed_classification
}

ggplot(df_aggregate, aes(x = as.factor(seed_classification), y = max_depth, fill = as.factor(seed_classification))) + 
  geom_boxplot() + 
  scale_fill_manual(values = color_map)

ggplot(df_aggregate, aes(x = as.factor(seed_classification), y = earliest_split_frac, fill = as.factor(seed_classification))) + 
  geom_boxplot() + 
  scale_fill_manual(values = color_map) +
  scale_y_continuous(limits = c(0,1))

ggplot(df_aggregate, aes(x = as.factor(seed_classification), y = earliest_split_frac, color = as.factor(seed_classification))) + 
  geom_jitter() + 
  scale_color_manual(values = color_map) + 
  scale_y_continuous(limits = c(0,1))

ggplot(df_combined_phylo, aes(x = as.factor(seed_classification), y = mean_pairwise_distance, fill = as.factor(seed_classification))) + 
  geom_boxplot() + 
  scale_fill_manual(values = color_map)

ggplot(df_combined_phylo, aes(x = as.factor(seed_classification), y = mean_pairwise_distance, fill = as.factor(seed_classification))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(seed_classification)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'none')

ggplot(df_combined_phylo, aes(x = as.factor(seed_classification), y = mean_evolutionary_distinctiveness, fill = as.factor(seed_classification))) + 
  geom_flat_violin(scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  geom_point(mapping=aes(color=as.factor(seed_classification)), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot( width = .1, outlier.shape = NA, alpha = 0.5 ) +
  scale_fill_manual(values = color_map) +
  scale_color_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'none')

ggplot(df_aggregate, aes(x = count_with_max_num_orgs)) + 
  geom_histogram(binwidth=1)

ggplot(df_aggregate, aes(x = num_orgs_max)) + 
  geom_histogram(binwidth=1)

ggplot(df_combined_phylo, aes(x = mean_pairwise_distance, y = mean_evolutionary_distinctiveness)) + 
  geom_point()
