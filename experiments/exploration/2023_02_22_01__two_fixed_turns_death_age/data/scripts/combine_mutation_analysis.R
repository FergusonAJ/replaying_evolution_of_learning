rm(list = ls())

# If we're in RStudio (i.e., local), hardcode directories
if(Sys.getenv("RSTUDIO") == 1){
  input_dir = '../data/reps/28/mutants/391'
  output_dir = input_dir
} else { # Else pull from command line args
  args = commandArgs(trailingOnly=TRUE)
  if(length(args) < 2){
    cat('Error! combine_mutation_classification.R expects exactly 2 command line arguments:\n')
    cat('    1. The input directory\n')
    cat('    2. The output directory\n')
    quit()
  }
  input_dir = args[1]
  output_dir = args[2]
}

df = NA
for(job_id in 1:200){
  input_filename = paste0(input_dir, '/mut_classification_', job_id, '.csv')
  df_tmp = read.csv(input_filename)
  if(!is.data.frame(df)){
    df = df_tmp
  } else {
    for(row_idx in 1:nrow(df_tmp)){
      row = df_tmp[row_idx,]
      if(row$seed_classification %in% df$seed_classification){
        mask = df$seed_classification == row$seed_classification
        new_count = row$count + df[mask,]$count
        new_merit = ((row$merit_mean_mean * row$count) + (df[mask,]$merit_mean_mean * df[mask,]$count)) / new_count
        new_accuracy = ((row$accuracy_mean_mean * row$count) + (df[mask,]$accuracy_mean_mean * df[mask,]$count)) / new_count
        df[mask,]$count = new_count
        df[mask,]$merit_mean_mean = new_merit
        df[mask,]$accuracy_mean_mean = new_accuracy
      } else {
        df[nrow(df) + 1,] = df
      }
    }
  }
}

write.csv(df, paste0(output_dir, '/combined_mutation_classification.csv'))

