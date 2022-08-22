rm(list = ls())

library(stringr)

args = commandArgs(trailingOnly=TRUE)
if(length(args) < 1){
    print('Error! Requires at least one argument: the depth of the org to extract.')
    quit()
}
org_depth = args[1]
col_name = 'genome'
if(length(args) > 1){
    col_name = args[2]
} 

df = read.csv('dominant_lineage.csv')
cat(df[df$depth == org_depth,col_name]) 
