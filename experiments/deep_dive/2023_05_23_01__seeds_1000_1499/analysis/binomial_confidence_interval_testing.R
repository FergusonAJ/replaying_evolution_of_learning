rm(list = ls())

library(Hmisc)
library(ggplot2)

df = data.frame(x = 0:50)

df$exact_lower = binconf(df$x, 50, alpha=0.05, method='exact')[,2]
df$exact_upper = binconf(df$x, 50, alpha=0.05, method='exact')[,3]
df$wilson_lower = binconf(df$x, 50, alpha=0.05, method='wilson')[,2]
df$wilson_upper = binconf(df$x, 50, alpha=0.05, method='wilson')[,3]
df$asymptotic_lower = binconf(df$x, 50, alpha=0.05, method='asymptotic')[,2]
df$asymptotic_upper = binconf(df$x, 50, alpha=0.05, method='asymptotic')[,3]

ggplot(df, aes(x = x)) + 
  geom_line(aes(y = x / 50)) + 
  #geom_ribbon(aes(ymin = exact_lower, ymax = exact_upper, fill = 'Exact'), alpha = 0.2) +
  geom_ribbon(aes(ymin = wilson_lower, ymax = wilson_upper, fill = 'Wilson'), alpha = 0.2)
  #geom_ribbon(aes(ymin = asymptotic_lower, ymax = asymptotic_upper, fill = 'Asymptotic'), alpha = 0.2)


df_mat = data.frame(data = matrix(nrow = 0, ncol = 3))
colnames(df_mat) = c('a', 'b', 'diff')
for(a in 0:50){
  a_upper = binconf(a, 50, alpha = 0.05, method='wilson')[,3]
  for(b in a:50){
    b_lower = binconf(b, 50, alpha = 0.05, method='wilson')[,2]
    cat(a, b, a_upper, b_lower, '\n')
    if(a_upper >= b_lower){
      df_mat[nrow(df_mat) + 1,] = c(a, b, 0)
      df_mat[nrow(df_mat) + 1,] = c(b, a, 0)
    } else{
      df_mat[nrow(df_mat) + 1,] = c(a, b, 1)
      df_mat[nrow(df_mat) + 1,] = c(b, a, 1)
    }
  }
}

ggplot(df_mat, aes(x = b, y = a, fill = diff)) + 
  geom_raster() +
  scale_y_reverse()
