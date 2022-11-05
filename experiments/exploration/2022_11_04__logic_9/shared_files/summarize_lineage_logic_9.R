rm(list=ls())

library(dplyr)

args = commandArgs(trailingOnly=TRUE)
if(length(args) != 2){
    print('Error! Expects exactly two arguments: the shared file directory and the seed of this replicate.')
    quit()
}

seed = args[2]
cat('Seed: ', seed, '\n')

df = NA

dplyr.summarise.inform = F

depth = 0
while(T){
    filename = paste0('dominant_lineage_fitness/depth_', depth, '.csv')
    if(!file.exists(filename)){
        break
    }
    print(paste0('Summarizing org at depth: ', depth))
    df_tmp = read.csv(filename)
    df_tmp$seed = seed
    df_tmp$depth = depth 
    df_grouped = dplyr::group_by(df_tmp, depth, seed)
    df_summary = dplyr::summarize(df_grouped, count = dplyr::n(), 
            merit_mean = mean(merit), merit_max = max(merit), merit_min = min(merit),
            genome_length = mean(genome_length),
            not_mean = mean(not),
            nand_mean = mean(nand),
            and_mean = mean(and),
            ornot_mean = mean(ornot),
            or_mean = mean(or),
            andnot_mean = mean(andnot),
            xor_mean = mean(xor),
            nor_mean = mean(nor),
            equ_mean = mean(equ),
            did_repro_mean = mean(did_repro))
    df_summary$depth = depth
    if(is.data.frame(df)){
        df = rbind(df, df_summary)
    }
    else{
        df = df_summary
    }    
    depth = depth + 1
}
write.csv(df, 'dominant_lineage_summary.csv')
