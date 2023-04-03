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
for(depth in 1:600){
  input_filename = paste0(input_dir, '/', depth, '/one_step_learning_summary_1.csv')
  df_tmp = read.csv(input_filename)
  cat(' ', depth)
  if(nrow(df_tmp) == 0){
      next
  }
  df_tmp$depth = depth
  if(!is.data.frame(df)){
    df = df_tmp
  } else {
    df = rbind(df, df_tmp)
  }
}
cat('\n')

write.csv(df, paste0(output_dir, '/combined_one_step_learning_summary.csv'))
cat('Done!\n')

warnings()
