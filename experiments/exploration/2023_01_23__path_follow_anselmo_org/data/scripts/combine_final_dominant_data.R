rm(list = ls())

args = commandArgs(trailingOnly=T)
if(length(args) != 2){
    print('Error! Expected exactly two args: 1) the scratch replicates directory and 2) the output directory!')
    quit()
}

reps_dir = args[1]
output_dir = args[2]

df = NA

for(i in 1:200){
    print(i)
    filename = paste0(reps_dir, '/', i, '/single_org_fitness.csv')
    if(!file.exists(filename)){
        next
    }
    df_tmp = read.csv(filename)
    df_tmp$seed = i
    if(is.na(df)){
        df = df_tmp
    }
    else{
        df = rbind(df, df_tmp)
    }
}

write.csv(df, paste0(output_dir, '/combined_final_dominant_data.csv'))
