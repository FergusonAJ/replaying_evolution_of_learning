rm(list = ls())

num_cues = 2

df = read.csv('./fitness.csv')
df = df[,colnames(df) != 'dominant_genome']

wd_parts = strsplit(getwd(), '/')[[1]]
df$rep_id = as.numeric(wd_parts[length(wd_parts)])

df$num_cues = num_cues


write.csv(df, 'scraped_fitness.csv')
