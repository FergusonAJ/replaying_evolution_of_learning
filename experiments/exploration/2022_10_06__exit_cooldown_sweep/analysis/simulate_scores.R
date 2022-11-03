rm(list = ls())

library(ggplot2)

regen = T
filename = '../data/sim_data.csv'
error_bases = c(1, 0, 0, 0, 0, 0, 0)
error_steps = c(0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.1)
max_correct = 200
max_incorrect = 200

if(!regen & file.exists(filename)){
  df = read.csv(filename)
}else{
  df = NA
  for(error_idx in 1:length(error_steps)){
    cat('Error index: ', error_idx, '\n')
    error_base = error_bases[error_idx]
    error_step = error_steps[error_idx]
    df_tmp = data.frame(data = matrix(nrow = max_correct * max_incorrect, ncol = 5))
    colnames(df_tmp) = c('error_base', 'error_step', 'correct_doors', 'incorrect_doors', 'score')
    row_idx = 1
    cat('Incorrect: ')
    for(incorrect_doors in 0:max_incorrect){
      cat(incorrect_doors, ' ')
      for(correct_doors in 0:max_correct){
        score = max(0, correct_doors - (error_base + incorrect_doors * error_step) * incorrect_doors)
        df_tmp[row_idx,] = c(error_base, error_step, correct_doors, incorrect_doors, score)
        row_idx = row_idx + 1
      }
    }
    cat('\n')
    if(!is.data.frame(df)){
      df = df_tmp
    } else{
      df = rbind(df, df_tmp)
    }
  }
  
  num_score_factors = 5
  score_factor_width = max(df$score) / num_score_factors
  df$score_factor = ceiling(df$score / score_factor_width) * score_factor_width
  write.csv(df, '../data/sim_data.csv')
}

 
df_diff = data.frame(data = matrix(nrow = max_correct * max_incorrect, ncol = 5))
diff_0_01 = df[df$error_step == 0,]$score - df[df$error_step == 0.01,]$score


ggplot(df, aes(x = correct_doors, y = incorrect_doors, fill = score)) + 
  geom_tile() + 
  facet_grid(cols = vars(error_step))

ggplot(df, aes(x = correct_doors, y = incorrect_doors, fill = as.factor(score_factor))) + 
  geom_tile() + 
  facet_grid(cols = vars(error_step))
