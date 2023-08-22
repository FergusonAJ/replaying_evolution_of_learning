rm(list = ls())

library(ggplot2)
library(dplyr)
library(tidyr)

df = read.csv('./seed_93__depths_730_750.csv')
df_summary = df %>% 
  group_by(start, seed) %>%
  #summarize(behavior_diff = max(behavior_lines_diff), execution_diff = max(execution_lines_diff), internal_diff = max(internal_lines_diff))
  summarize(behavior_diff = max(behavior_lines_diff), internal_diff = max(internal_lines_diff))

#df_tidy = pivot_longer(df_summary, cols = c('behavior_diff', 'execution_diff', 'internal_diff'), names_to = 'diff_type')
df_tidy = pivot_longer(df_summary, cols = c('behavior_diff', 'internal_diff'), names_to = 'diff_type')

ggplot(df_tidy[df_tidy$value == 1 & df_tidy$diff_type != 'execution_diff',], aes(x = start, y = as.factor(diff_type))) + 
  geom_tile()

