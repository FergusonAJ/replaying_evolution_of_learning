rm(list = ls())

args = commandArgs(trailingOnly=T)
if(length(args) != 3){
    print('Error! Expected exactly three args: ')
    print('1) the scratch replicates directory') 
    print('2) the output directory!')
    print('3) the number of replicates to scrape!')
    quit()
}

reps_dir = args[1]
output_dir = args[2]
num_reps = as.numeric(args[3])

df = NA
seeds = 1:num_reps
#seeds = c(173,175,178,444)

for(i in seeds){
    cat(i)
    #filename = paste0(reps_dir, '/', i, '/final_dom_org_fitness.csv')
    filename = paste0(reps_dir, '/', i, '/single_org_fitness.csv')
    if(!file.exists(filename)){
        cat('(X)')
        next
    }
    df_tmp = read.csv(filename)
    df_tmp$seed = i
    if(!is.data.frame(df)){
        df = df_tmp
    }
    else{
        df = rbind(df, df_tmp)
    }
    cat(' ')
}
cat('\n')

write.csv(df, paste0(output_dir, '/combined_final_dominant_data.csv'))
