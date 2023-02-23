rm(list = ls())

# If we're in RStudio (i.e., local), hardcode directories
if(Sys.getenv("RSTUDIO") == 1){
  input_dir = '../data/reps/28/mutants/391'
  output_dir = input_dir
} else { # Else pull from command line args
  args = commandArgs(trailingOnly=TRUE)
  if(length(args) < 2){
    cat('Error! combine_learning_muts.R expects exactly 2 command line arguments:\n')
    cat('    1. The input directory\n')
    cat('    2. The output directory\n')
    quit()
  }
  input_dir = args[1]
  output_dir = args[2]
}

df_list = list()
for(job_id in 1:200){
  input_filename = paste0(input_dir, '/learning_summary_', job_id, '.csv')
  df_tmp = read.csv(input_filename)
  if(nrow(df_tmp) == 0){
      next
  }
  df_list = append(df_list, list(df_tmp))
}
df = do.call('rbind', df_list)

write.csv(df, paste0(output_dir, '/combined_learning_summary.csv'))

warnings()
