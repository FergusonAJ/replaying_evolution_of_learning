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


df = read.csv(paste0(input_dir, '/combined_learning_summary.csv'))

# Plot number of replicates classified as each category
ggplot(df) + 
  geom_histogram(mapping = aes(x = merit_mean), bins=50) + 
  xlab('Mean merit') +
  scale_x_continuous(trans = 'log2')
ggsave(paste0(output_dir, '/two_step_learning_mut_merit.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(output_dir, '/two_step_learning_mut_merit.png'), width = 9, height = 6, units = 'in')
