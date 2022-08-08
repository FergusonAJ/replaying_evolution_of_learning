rm(list=ls())

library(dplyr)

args = commandArgs(trailingOnly=TRUE)
if(length(args) != 2){
    print('Error! Expects exactly two arguments: the shared file directory and the seed of this replicate.')
    quit()
}

shared_file_dir = args[1]

source(paste0(shared_file_dir, '/constant_vars.R'))
source(paste0(shared_file_dir, '/shared_funcs.R'))

seed = args[2]
cat('Seed: ', seed, '\n')

df = NA

dplyr.summarise.inform = F

for(depth in 0:10000){
    filename = paste0('dominant_lineage_fitness/depth_', depth, '.csv')
    if(!file.exists(filename)){
        break
    }
    print(paste0('Summarizing org at depth: ', depth))
    df_tmp = read.csv(filename)
    df_tmp$seed = seed
    df_tmp$depth = depth 
    df_summary = summarize_final_dominant_org_data(df_tmp)
    df_summary$depth = depth
    if(is.data.frame(df)){
        df = rbind(df, df_summary)
    }
    else{
        df = df_summary
    }    
}
write.csv(df, 'dominant_lineage_summary.csv')
