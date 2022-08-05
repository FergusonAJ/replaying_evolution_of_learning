rm(list = ls())

library(ggplot2)
library(dplyr)

source('./constant_vars.R')
source('./shared_funcs.R')

df = read.csv('../data/combined_final_dominant_data.csv')
df = classify_individual_trials(df)
df = classify_seeds(df)
df_summary = summarize_final_dominant_org_data(df)
classification_summary = summarize_classifications(df_summary)

df_summary = df_summary[order(df_summary$accuracy_mean),]
df_summary$seed_order = 1:nrow(df_summary)
ggplot(df_summary, aes(x = seed_order, color = seed_classification)) + 
  geom_point(aes(y = accuracy_mean)) +
  geom_point(aes(y = accuracy_min), alpha = 0.2) +
  geom_point(aes(y = accuracy_max), alpha = 0.2) +
  scale_color_manual(values = color_map)

ggplot(df, aes(x = seed, y = accuracy, color = seed_classification)) + 
  geom_point(alpha = 0.2) + 
  scale_color_manual(values = color_map)

df$seed_order = NA
for(seed in unique(df$seed)){
  df[df$seed == seed,]$seed_order = df_summary[df_summary$seed == seed,]$seed_order
}
ggplot(df, aes(x = seed_order, y = accuracy, color = seed_classification)) + 
  geom_point(alpha = 0.2) +
  scale_color_manual(values = color_map)

# Plot number of replicates classified as each category
ggplot(classification_summary, aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
  geom_col() + 
  geom_text(aes(y = count + 3, label = count)) + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  ylab('Number of replicates') + 
  theme(legend.position = 'none')

ggplot(df_summary, aes(x = seed_classification_factor, y = merit_mean, fill = seed_classification_factor)) + 
  geom_boxplot() + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'none')
  
ggplot(df_summary, aes(x = seed_classification_factor, y = accuracy_mean, fill = seed_classification_factor)) + 
  geom_boxplot() + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'none')

ggplot(df_summary, aes(x = seed_classification_factor, y = door_rooms_mean, fill = seed_classification_factor)) + 
  geom_boxplot() + 
  scale_fill_manual(values = color_map) + 
  xlab('Classification') + 
  theme(legend.position = 'none')



print('Learning reps:')
sort(df_summary[df_summary$seed_classification == seed_class_learning,]$seed)
print('Bet-hedged imprinting reps:')
sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed)
print('Error correction reps:')
sort(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed)
print('Bet-hedged error correction reps:')
sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)
print('Other reps:')
sort(df_summary[df_summary$seed_classification == seed_class_other,]$seed)
print('Small reps:')
sort(df_summary[df_summary$seed_classification == seed_class_small,]$seed)

