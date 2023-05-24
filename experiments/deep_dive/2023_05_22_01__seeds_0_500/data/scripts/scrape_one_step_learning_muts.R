rm(list = ls())

library(ggplot2)

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


df = read.csv(paste0(input_dir, 'combined_learning_summary.csv'))

df_one_step = df[grep('x-1', df$seed, fixed=T),]
write.csv(df_one_step, paste0(output_dir, 'one_step_learning_muts.csv') )

