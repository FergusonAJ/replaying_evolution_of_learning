rm(list = ls())

args = commandArgs(trailingOnly=TRUE)
if(length(args) < 1){
    print('Error! Requires at least one filename to check!')
    quit()
}

max_merit = 0
max_filename = NA
for(filename in args){
    df = read.csv(filename)
    mean_merit = mean(df$merit)
    if(mean_merit > max_merit){
        max_merit = mean_merit
        max_filename = filename
    }
} 
cat(paste0(filename, '\n'))
