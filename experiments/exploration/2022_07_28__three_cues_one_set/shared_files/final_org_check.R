rm(list = ls())
df = read.csv('max_org.csv')
final_org = df[nrow(df),]
if(final_org$correct_doors > 50 & final_org$accuracy > 0.75){
  write.csv('foo', 'successfully_evolved.txt')
  if(final_org$incorrect_doors == 0 & final_org$incorrect_exits == 0){
    write.csv('foo', 'optimally_evolved.txt')
  }
}
