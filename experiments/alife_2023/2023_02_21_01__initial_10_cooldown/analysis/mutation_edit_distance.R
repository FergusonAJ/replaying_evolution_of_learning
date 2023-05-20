rm(list = ls())

library(ggplot2)

get_edit_distance = function(str_a, str_b){
  num_rows = nchar(str_a) + 1
  num_cols = nchar(str_b) + 1
  dp_matrix = matrix(nrow = nchar(str_a) + 1, ncol = nchar(str_b) + 1)
  dp_matrix[1,1] = 0
  for(row in 2:num_rows){
    dp_matrix[row,1] = row - 1
  }
  for(col in 2:num_cols){
    dp_matrix[1,col] = col - 1
  }
  for(row in 2:num_rows){
    char_a = substring(str_a, row-1, row-1)
    for(col in 2:num_cols){
      char_b = substring(str_b, col-1, col-1)
      if(char_a == char_b){
        dp_matrix[row,col] = dp_matrix[row-1, col-1]
      } else {
        dp_matrix[row,col] = 1 + min(
            dp_matrix[row-1, col-1],
            dp_matrix[row-1, col],
            dp_matrix[row, col-1] )
      }
    }
  }
  return(dp_matrix)
}

get_move = function(str_a, str_b, dp_matrix, row, col){
  if(row == 1 && col == 1){ # Back to top left -> Nothing to do
    return('At origin')
  } else if (row == 1){ # On top row -> Add to str_a
    res = paste0('Add ', substring(str_b, col-1, col-1), ' to ', str_a, ' at index ', col - 1)
    return(res)
  } else if (col == 1){ # On left column -> Add to str_b
    res = paste0('Add ', substring(str_a, row-1, row-1), ' to ', str_b, ' at index ', row - 1)
    return(res)
  } else if (dp_matrix[row, col] == (dp_matrix[row-1, col-1] + 1)){
    res = paste0('Swap ', substring(str_a, row-1, row-1), ' with ', substring(str_b, col-1, col-1))
    return(res)
  } else if(dp_matrix[row, col] == dp_matrix[row-1,col-1]){
    return("No change")
  } else{
    return("Unable to deduce operation")
  } 
}

get_all_changes = function(str_a, str_b, dp_matrix){
  row = nrow(dp_matrix)
  col = ncol(dp_matrix)
  changes = list()
  while(row != 1 || col != 1){
    if (row == 1){ # On top row -> Add to str_a
      changes[[length(changes) + 1]] = c('add', substring(str_b, col-1, col-1), row - 1)
      col = col - 1
      next
    } else if (col == 1){ # On left column -> Add to str_b
      changes[[length(changes) + 1]] = c('remove', substring(str_a, row-1, row-1), row - 1)
      row = row - 1
      next
    } 
    start_val = dp_matrix[row, col]
    diag_val = dp_matrix[row-1, col-1]
    left_val = dp_matrix[row, col-1]
    up_val = dp_matrix[row-1,col]
    #cat('row:', row, ' col:', col, '\n')
    #cat('  start_val:', start_val, '\n')
    #cat('  diag_val:', diag_val, '\n')
    #cat('  left_val:', left_val, '\n')
    #cat('  up_val:', up_val, '\n')
    best_val = min(diag_val, left_val, up_val)
    if(best_val == diag_val){
      if(best_val == start_val - 1){
        changes[[length(changes) + 1]] = c('swap', substring(str_a, row-1, row-1), row - 1, substring(str_b, col-1, col-1))
      }
      row = row - 1
      col = col - 1
    } else if(best_val == up_val){
      changes[[length(changes) + 1]] =c('remove', substring(str_a, row-1, row-1), row - 1)
      row = row - 1
    } else if(best_val == left_val){
      changes[[length(changes) + 1]] = c('add', substring(str_b, col-1, col-1), row)
      col = col - 1
    } else{
      return(NA)
    } 
  }
  return(changes)
}

seed = 86
df = read.csv(paste0('../data/reps/',seed,'/dominant_lineage.csv'))
remove_vec = c()
df = df[order(df$depth),]
#test_genomes = c( 'austin', 'Austin', 'Autin', 'Authin', 'Authen', 'Autheni', 'Authenic', 'Authentic' )
#df[1:length(test_genomes),]$genome = test_genomes
#df = df[1:8,]
#df = df[1:150,]
genomes = df[order(df$depth),]$genome

#for(start in 0:(length(test_genomes)-2)){#$(max(df$depth) - 1)){
for(start in 0:(sort(df$depth, decreasing=T)[2])){
  str_a = df[df$depth == start,]$genome
  if(sum(df$depth == start+1) == 0){
    next
  }
  str_b = df[df$depth == start+1,]$genome
  dp_matrix = get_edit_distance(str_a, str_b)
  change_vec = get_all_changes(str_a, str_b, dp_matrix)
  if(!is.list(change_vec)){
    cat('NA returned for start: ', start, '\n')
  }
  cat(start, ' -> ', start+1, '\n')
  for(rem_idx in remove_vec){
    prefix = substring(genomes[start+1], 1, rem_idx - 1)
    suffix = substring(genomes[start+1], rem_idx, nchar(genomes[start+1]))
    genomes[start+1] = paste0(prefix, '$', suffix)
  }
  for(change in change_vec){
    #cat(' ', change, '\n')
    if(change[1] == 'swap'){
      # Do nothing on swap
    }else if(change[1] == 'add'){
      char = change[2]
      idx = as.numeric(change[3])
      actual_chars = 0
      empty_chars = 0
      char_idx = 1
      while(T){
        test_char = substring(genomes[start+1], char_idx, char_idx)
        if(test_char == '$'){
          empty_chars = empty_chars + 1
        } else {
          actual_chars = actual_chars + 1
          if(actual_chars >= idx){
            break
          }
        }
        char_idx = char_idx + 1 
      }
      idx = idx + empty_chars
      for(add_idx in 1:(start+1)){
        prefix = substring(genomes[add_idx], 1, idx - 1)
        suffix = substring(genomes[add_idx], idx, nchar(genomes[add_idx]))
        genomes[add_idx] = paste0(prefix, '$', suffix)
      }
      if(length(remove_vec) > 0){
        for(rem_idx in 1:length(remove_vec)){
          if(remove_vec[rem_idx] >= idx){
            remove_vec[rem_idx] = remove_vec[rem_idx] + 1
          }
        }
      }
    }else if(change[1] == 'remove'){
      char = change[2]
      idx = as.numeric(change[3])
      actual_chars = 0
      empty_chars = 0
      char_idx = 1
      while(T){
        test_char = substring(genomes[start+1], char_idx, char_idx)
        if(test_char == '$'){
          empty_chars = empty_chars + 1
        } else {
          actual_chars = actual_chars + 1
          if(actual_chars >= idx){
            break
          }
        }
        char_idx = char_idx + 1 
      }
      idx = idx + empty_chars#sum(remove_vec <= idx)
      remove_vec = sort(c(remove_vec, idx))
      #for(rem_idx in 1:length(remove_vec)){
      #  if(remove_vec[rem_idx] > idx){
      #    remove_vec[rem_idx] = remove_vec[rem_idx] + 1
      #  }
      #}
    }
  }
}
# Add empty slots to final genome  
for(rem_idx in remove_vec){
  prefix = substring(genomes[length(genomes)], 1, rem_idx - 1)
  suffix = substring(genomes[length(genomes)], rem_idx, nchar(genomes[length(genomes)]))
  genomes[length(genomes)] = paste0(prefix, '$', suffix)
}
genomes[1:min(length(genomes), 25)]
genomes[(length(genomes) - 100):length(genomes)]

max_len = 0
for(i in 1:length(genomes)){
  if(nchar(genomes[i]) > max_len){
    max_len = nchar(genomes[i])
  }
}
cat('\n')

seq_matrix = matrix(nrow = length(genomes), ncol = max_len)
for(row in 1:length(genomes)){
  for(col in 1:max_len){
    cat(row, col, '\n')
    seq_matrix[row, col] = substring(genomes[row], col, col)
  }
}
write.csv(seq_matrix, paste0('../data/reps/',seed,'/seq_data.csv'))


df_site_changes = data.frame(data = matrix(nrow = 0, ncol = 4))
cur_sites = rep(NA, max_len)
colnames(df_site_changes) = c('site', 'char', 'start', 'end')
for(row in 1:length(genomes)){
  cat('Row ', row, '\n')
  for(col in 1:max_len){
    char = seq_matrix[row,col]
    if(char == '$'){
      if(is.na(cur_sites[col]) || cur_sites[col] == '$'){
        next
      } else {
        df_site_changes[df_site_changes$site == col & is.na(df_site_changes$end),]$end = row
        cur_sites[col] = '$'
        next
      }
    } else {
      if(is.na(cur_sites[col])){
        df_site_changes[nrow(df_site_changes) + 1,] = c(col, char, row, NA)
        cur_sites[col] = char
      } else if(char != cur_sites[col]){
        df_site_changes[df_site_changes$site == col & is.na(df_site_changes$end),]$end = row
        df_site_changes[nrow(df_site_changes) + 1,] = c(col, char, row, NA)
        cur_sites[col] = char
      }
    }
  }
}
df_site_changes$site = as.numeric(df_site_changes$site)
df_site_changes$start = as.numeric(df_site_changes$start)
df_site_changes$end = as.numeric(df_site_changes$end)

df_site_changes[is.na(df_site_changes$end),]$end = length(genomes)
df_site_changes$duration = df_site_changes$end - df_site_changes$start

df_site_changes$max_possible_duration = max(df$depth) - df_site_changes$start
df_site_changes$duration_frac = (df_site_changes$duration-1) / df_site_changes$max_possible_duration

ggplot(df_site_changes, aes(x = duration)) + 
  geom_histogram()

df_site_changes[df_site_changes$duration > 500,]

