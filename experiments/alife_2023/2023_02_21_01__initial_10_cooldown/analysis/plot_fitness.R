rm(list = ls())

rep_data_dir = '../data/reps/86'
df = read.csv(paste0(rep_data_dir, '/fitness.csv'))
df$update = 1:nrow(df)

df_trimmed = df[df$update %% 100 == 0,]

ggplot(df_trimmed, aes(x = update, y = merit_mean)) +
  geom_line() + 
  scale_y_continuous(trans = 'log2')

ggplot(df_trimmed, aes(x = update, y = gen_mean)) +
  geom_line() 

df_trimmed = data.frame(data=matrix(nrow = 0, ncol = 4))
colnames(df_trimmed) = c('start_update', 'stop_update', 'median_mean_merit', 'mean_mean_merit')
for(start_update in seq(1, nrow(df), 1000)){
  cat(start_update, '\n')
  stop_update = start_update + 99  
  merit_mean_vec = df[df$update >= start_update & df$update <= stop_update,]$merit_mean
  df_trimmed[nrow(df_trimmed) + 1,] = c(start_update, stop_update, median(merit_mean_vec), mean(merit_mean_vec))  
}

ggplot(df_trimmed, aes(x = start_update, y = median_mean_merit)) +
  geom_line() +
  scale_y_continuous(trans = 'log2')
