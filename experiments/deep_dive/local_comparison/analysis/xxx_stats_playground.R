rm(list = ls())

library(Hmisc)
library(ggplot2)

N = 50
df = data.frame(data = matrix(nrow = 0, ncol = 3))

for(n_a in 0:N){
  for(n_b in 0:N){
    mat = matrix(data = c(n_a, N - n_a, n_b, N - n_b), nrow = 2, ncol = 2)
    results = fisher.test(mat, alternative = 'two.sided', conf.int = F)
    df[nrow(df) + 1,] = c(n_a, n_b, results$p.value)
  }
}
colnames(df) = c('a', 'b', 'p')

ggplot(df, aes(x = a, y = b, fill = p)) + 
  geom_tile()
ggplot(df[df$p < 0.01,], aes(x = a, y = b, fill = p)) + 
  geom_tile()
