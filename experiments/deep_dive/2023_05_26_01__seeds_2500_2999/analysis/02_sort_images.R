rm(list = ls())

# Local include
source('./local_setup.R')

# Load processed data
df_summary = load_processed_summary()

image_sorting_str = ''

# First, move the files out of individual directories
image_sorting_str = paste0(image_sorting_str, '#!/bin/bash\n\n')
image_sorting_str = paste0(image_sorting_str, '# First, move the files out of individual directories\n')
image_sorting_str = paste0(image_sorting_str, 'for NUM in {1..', max(df_summary$seed), '}\n')
image_sorting_str = paste0(image_sorting_str, 'do\n')
image_sorting_str = paste0(image_sorting_str, '  mv ${NUM}/out.png rep_${NUM}.png\n')
image_sorting_str = paste0(image_sorting_str, '  rm ${NUM} -r\n')
image_sorting_str = paste0(image_sorting_str, 'done\n\n')


# Sort images into respective directories via generated shell script
image_sorting_str = paste0(image_sorting_str, '# Sort the files!\n')
# Learning
if(length(df_summary[df_summary$seed_classification == seed_class_learning,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str,  'mkdir -p learning\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_learning,]$seed)){
  image_sorting_str = paste0(image_sorting_str,  'mv rep_', seed, '.png learning;\n')
}
# Bet-hedged imprinting
if(length(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p bet_hedged_imprinting\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_learning,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png bet_hedged_imprinting;\n')
}
# Error correction
if(length(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p error_correction\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_error_correction,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png error_correction;\n')
}
# Bet-hedged error correction
if(length(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p bet_hedged_error_correction\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_error_correction,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png bet_hedged_error_correction;\n')
}
# Mixed bet-hedging
if(length(df_summary[df_summary$seed_classification == seed_class_bet_hedged_mixed,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p mixed_bet_hedging\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_bet_hedged_mixed,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png mixed_bet_hedging;\n')
}
if(length(df_summary[df_summary$seed_classification == seed_class_small,]$seed) > 0){
  image_sorting_str = paste0(image_sorting_str, 'mkdir -p small\n')
}
for(seed in sort(df_summary[df_summary$seed_classification == seed_class_small,]$seed)){
  image_sorting_str = paste0(image_sorting_str, 'mv rep_', seed, '.png small;\n')
}

# Save!
image_dir = '../images'
if(!dir.exists(image_dir)){
  dir.create(image_dir)
}
sorting_script_filename = paste0(image_dir, '/sort.sh')
write(image_sorting_str, sorting_script_filename)
cat('Saved sorting script to: ', sorting_script_filename, '\n')
system(paste0('chmod u+x ', sorting_script_filename))
cat('Made script executable\n')



