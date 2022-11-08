rm(list = ls())

library(stringr)

# If we passed a value, use it for the final update
final_update = 250000
args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
    final_update = args[1]
}

filename = paste0('phylo/phylogeny_manual_', final_update, '.csv')
df = read.csv(filename)
df$ancestor_list = stringr::str_remove(df$ancestor_list, '\\[')
df$ancestor_list = stringr::str_remove(df$ancestor_list, '\\]')

df_extant = df[df$destruction_time == Inf,]

# Extract dominant org with the highest merit (tested outside file)
dominant_org_genome = read.csv('./final_dominant_org_fitness.csv')$genome[1]
dominant_org = df_extant[df_extant$num_orgs == max(df_extant$num_orgs),]
dominant_org = dominant_org[dominant_org$taxon_info == dominant_org_genome,]

stop_idx = stringr::str_locate(dominant_org$taxon_info, '\\]')[[2]]
genome = str_sub(dominant_org$taxon_info, stop_idx + 1)
print(paste0('Final dominant genotype: ', genome))
fp = file('final_dominant_char.org', 'w')
writeChar(paste0(genome, '\n'), fp, eos = NULL)
close(fp)

df_lineage = dominant_org
cur_org = dominant_org
while(cur_org$ancestor_list != 'NONE'){
  cur_org = df[df$id == cur_org$ancestor_list,]
  df_lineage = rbind(df_lineage, cur_org)
}

df_lineage$genome = NA
for(org_idx in 1:nrow(df_lineage)){
  org = df_lineage[org_idx,]
  start_idx = stringr::str_locate(org$taxon_info, '\\[')[[1]]
  stop_idx = stringr::str_locate(org$taxon_info, '\\]')[[2]]
  df_lineage[org_idx,]$genome = str_sub(org$taxon_info, stop_idx + 1)
  df_lineage[org_idx,]$genome_length = str_sub(org$taxon_info, start_idx + 1, stop_idx - 1)
}
write.csv(df_lineage, 'dominant_lineage.csv')
