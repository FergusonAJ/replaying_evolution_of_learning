rm(list=ls())

library(dplyr)

args = commandArgs(trailingOnly=TRUE)
if(length(args) != 1){
    print('Error! Expects exactly one argument: the seed of this replicate.')
    quit()
}
seed = args[1]

df = NA

for(depth in 0:10000){
    filename = paste0('dominant_lineage_fitness/depth_', depth, '.csv')
    if(!file.exists(filename)){
        break
    }
    print(paste0('Summarizing org at depth: ', depth))
    df_tmp = read.csv(filename)
    df_tmp$seed = seed
    df_grouped = dplyr::group_by(df_tmp, seed)
    df_summary = dplyr::summarize(df_grouped, count = dplyr::n(), 
                                  accuracy_mean = mean(accuracy), 
                                    accuracy_max = max(accuracy), 
                                    accuracy_min = min(accuracy),
                                  merit_mean = mean(merit), 
                                    merit_max = max(merit), 
                                    merit_min = min(merit),
                                  door_rooms_mean = mean(door_rooms), 
                                    door_rooms_max = max(door_rooms), 
                                    door_rooms_min = min(door_rooms),
                                  exit_rooms_mean = mean(exit_rooms), 
                                    exit_rooms_max = max(exit_rooms), 
                                    exit_rooms_min = min(exit_rooms),
                                  correct_doors_mean = mean(correct_doors), 
                                    correct_doors_max = max(correct_doors), 
                                    correct_doors_min = min(correct_doors),
                                  incorrect_doors_mean = mean(incorrect_doors), 
                                    incorrect_doors_max = max(incorrect_doors), 
                                    incorrect_doors_min = min(incorrect_doors),
                                  correct_exits_mean = mean(correct_exits), 
                                    correct_exits_max = max(correct_exits), 
                                    correct_exits_min = min(correct_exits),
                                  incorrect_exits_mean = mean(incorrect_exits), 
                                    incorrect_exits_max = max(incorrect_exits), 
                                    incorrect_exits_min = min(incorrect_exits),
                                  genome_length = mean(genome_length))
    df_summary$depth = depth
    if(is.data.frame(df)){
        df = rbind(df, df_summary)
    }
    else{
        df = df_summary
    }    
}
write.csv(df, 'dominant_lineage_summary.csv')
