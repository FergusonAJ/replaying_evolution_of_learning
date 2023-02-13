rm(list = ls())

library(ggplot2)

df = read.csv('../data/combined_final_max_data.csv')

ggplot(df, aes(x = seed, y = merit)) + 
  geom_point() + 
  scale_y_continuous(trans='log2')

ggplot(df, aes(x = seed, y = accuracy)) + 
  geom_point() 

df_plot = df[df$correct_doors < 10^6,]
ggplot(df_plot, aes(x = correct_doors, y = merit)) + 
  geom_point() + 
  scale_y_continuous(trans='log2')

df_plot = df[df$correct_doors < 10^6,]
ggplot(df_plot, aes(x = correct_doors, y = incorrect_doors)) + 
  geom_point()

df_plot = df[df$correct_doors < 10^6,]
ggplot(df_plot, aes(x = accuracy, y = correct_doors)) + 
  geom_point(alpha = 0.2)
