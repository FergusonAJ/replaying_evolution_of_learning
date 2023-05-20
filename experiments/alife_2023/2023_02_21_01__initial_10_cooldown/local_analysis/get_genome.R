rm(list = ls())

args = commandArgs(trailingOnly=TRUE)
if(length(args) < 2){
  cat('Error! get_genome.R expects exactly 2 command line arguments:\n')
  cat('    1. The seed of the replicate\n')
  cat('    2. The depth to extract\n')
  quit()
}
seed = args[1]
depth = args[2]

filename = paste0('../data/reps/', seed, '/dominant_lineage.csv')
if(!file.exists(filename)){
  cat('Error! File does not exist: ', filename, '\n')
  quit()
}
df = read.csv(filename)
cat(df[df$depth == depth,]$genome, '\n')
