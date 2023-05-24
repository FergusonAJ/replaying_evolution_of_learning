rm(list=ls())

library(dplyr)

args = commandArgs(trailingOnly=TRUE)
if(length(args) != 5){
    print('Error! Expects exactly five arguments: ')
    print('  1. the shared file directory')
    print('  2. the seed of this replicate')
    print('  3. the depth of this organism ')
    print('  4. the input filename')
    print('  5. the filename of the resulting csv')
    quit()
}

shared_file_dir = args[1]

source(paste0(shared_file_dir, '/constant_vars__three_cues_one_set.R'))
source(paste0(shared_file_dir, '/shared_funcs__three_cues_one_set.R'))

seed = args[2]
cat('Seed: ', seed, '\n')
org_depth = args[3]
cat('Org depth: ', org_depth, '\n')
input_filename = args[4]
cat('Input filename: ', input_filename, '\n')
output_filename = args[5]
cat('Output filename: ', output_filename, '\n')

dplyr.summarise.inform = F

depth = 0
if(!file.exists(input_filename)){
    cat('Input file not found, exiting!\n')
    quit()
}
df_tmp = read.csv(input_filename)
df_tmp$seed = seed
df_tmp$depth = org_depth 
df_summary = summarize_final_dominant_org_data(df_tmp)
df_summary$depth = org_depth

# If this isn't the first iteration, combine with old data
if(file.exists(output_filename)){
    df = read.csv(output_filename)
    df = rbind(df, df_summary)
    write.csv(df, output_filename, row.names=F)
}else{ # If this is the first iteration, write as is
    write.csv(df_summary, output_filename, row.names=F)
}    
