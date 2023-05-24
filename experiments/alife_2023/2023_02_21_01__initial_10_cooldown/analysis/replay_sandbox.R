rm(list = ls())

library(ggplot2)
library(dplyr)

seed = 100
processed_data_dir = paste0('../data/reps/', seed, '/replays/processed_data/')
df = read.csv(paste0(processed_data_dir, '/processed_replay_data.csv'))
df_summary = read.csv(paste0(processed_data_dir, '/processed_replay_summary.csv'))
classification_summary = read.csv(paste0(processed_data_dir, '/processed_replay_classification.csv'))

df_depth_counts = dplyr::summarize(dplyr::group_by(classification_summary, depth), count = sum(count)) 
df_learning_counts = classification_summary[classification_summary$seed_classification == 'Learning',]
df_learning_counts$total_count = df_depth_counts[df_depth_counts$depth == df_learning_counts$depth,]$count
df_learning_counts$missed_count = df_learning_counts$total_count - df_learning_counts$count
  
z = 1.96
df_learning_counts$upper = (
  (df_learning_counts$count  + 0.5 * z^2) / (df_learning_counts$total_count + z^2)) +
  (z/(df_learning_counts$total_count + z^2)) * sqrt(
    ((df_learning_counts$count  * df_learning_counts$missed_count) / df_learning_counts$total_count) +
    (z^2/4)
  )
df_learning_counts$lower = (
  (df_learning_counts$count  + 0.5 * z^2) / (df_learning_counts$total_count + z^2)) -
  (z/(df_learning_counts$total_count + z^2)) * sqrt(
    ((df_learning_counts$count  * df_learning_counts$missed_count) / df_learning_counts$total_count) +
    (z^2/4)
  )

ggplot(df_learning_counts, aes(x = depth)) + 
  geom_errorbar(aes(ymin = lower, ymax = upper), alpha = 0.5) +
  geom_line(aes(y = frac)) +
  geom_point(aes(y = frac))

df_learning_counts$fisher_p_val = NA
for(depth in unique(df_learning_counts$depth)){
  if(depth == min(df_learning_counts$depth)){
    next
  } 
  successes = df_learning_counts[df_learning_counts$depth == depth,]$count
  total = df_learning_counts[df_learning_counts$depth == depth,]$total_count
  failures = total - successes
  prev_depth = max(df_depth_counts[df_depth_counts$depth < depth,]$depth)
  prev_successes = df_learning_counts[df_learning_counts$depth == prev_depth,]$count
  prev_total = df_learning_counts[df_learning_counts$depth == prev_depth,]$total_count
  prev_failures = prev_total - prev_successes
  contingency_table = matrix(nrow = 2, ncol = 2)
  contingency_table[1,1] = successes
  contingency_table[1,2] = failures
  contingency_table[2,1] = prev_successes
  contingency_table[2,2] = prev_failures
  fisher_results = fisher.test(contingency_table)  
  df_learning_counts[df_learning_counts$depth == depth,]$fisher_p_val = fisher_results$p.value
}

df_learning_counts$fisher_p_val_corrected = NA
p_val_mask = !is.na(df_learning_counts$fisher_p_val)
df_learning_counts[p_val_mask,]$fisher_p_val_corrected = p.adjust(df_learning_counts[p_val_mask,]$fisher_p_val, method = 'holm')

ggplot(df_learning_counts, aes(x = depth)) + 
  geom_line(aes(y = frac)) +
  geom_point(aes(y = frac)) +
  geom_point(data = df_learning_counts[df_learning_counts$fisher_p_val_corrected < 0.05,], aes(y = frac), color='#cc5500') +
  geom_text(aes(y = frac + 0.1, label = round(fisher_p_val_corrected, 3)))
df_depth_counts$count
