rm(list = ls())

library(ggplot2)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')

# This script is simply used to generate a legend for the combined replay plot
# Thus, we create a fake data frame that holds the necessary classifications


df_legend = data.frame(data = matrix(nrow = 0, ncol = 2))
colnames(df_legend) = c('id', 'seed_classification')
df_legend[nrow(df_legend) + 1,] = c(1, seed_class_learning)
df_legend[nrow(df_legend) + 1,] = c(2, seed_class_bet_hedged_learning)
df_legend[nrow(df_legend) + 1,] = c(3, seed_class_error_correction)
df_legend[nrow(df_legend) + 1,] = c(4, seed_class_bet_hedged_error_correction)
df_legend[nrow(df_legend) + 1,] = c(5, seed_class_bet_hedged_mixed)
df_legend[nrow(df_legend) + 1,] = c(6, seed_class_small)

df_legend$id = as.numeric(df_legend$id)

order_vec = c(
  seed_class_learning, 
  seed_class_bet_hedged_learning, 
  seed_class_error_correction, 
  seed_class_bet_hedged_error_correction, 
  seed_class_bet_hedged_mixed, 
  seed_class_small)
df_legend$classification_factor = factor(df_legend$seed_classification, levels = order_vec)

local_color_map = color_map[names(color_map) != seed_class_other]

ggplot(df_legend, aes(xmin=id, xmax=id+1, ymin=0, ymax=1, fill = classification_factor)) + 
  geom_rect() +
  scale_fill_manual(values = local_color_map, drop=T) + 
  labs(fill = 'Classification') +
  theme(axis.text = element_text(size = 16)) +
  theme(axis.title = element_text(size = 18)) +
  theme(legend.text = element_text(size = 16)) +
  theme(legend.title = element_text(size = 18)) +
  theme(legend.position = 'bottom')
  ggsave('../plots/combined_plot_legend.pdf', width = 12, height = 6, units = 'in')
  ggsave('../plots/combined_plot_legend.png', width = 12, height = 6, units = 'in')
