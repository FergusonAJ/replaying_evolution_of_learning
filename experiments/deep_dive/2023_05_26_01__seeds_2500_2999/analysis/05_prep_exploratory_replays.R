rm(list = ls())

library(ggplot2)

# Local include
source('./local_setup.R')

# Figure out which seeds to process
df_summary = load_processed_summary_after_lineage_analysis()
seeds_to_process = get_seeds_to_process()

slurm_replay_str = 'REPLAY_SEEDS="'
for(seed in seeds_to_process){
  if(seed != seeds_to_process[1]){
    slurm_replay_str = paste0(slurm_replay_str, ' ')
  }
  slurm_replay_str = paste0(slurm_replay_str, seed)
}
slurm_replay_str = paste0(slurm_replay_str, '"\ndeclare -a DEPTH_MAP\n')
for(seed in seeds_to_process){
  slurm_replay_str = paste0(slurm_replay_str, 'DEPTH_MAP[', seed, ']="')
  min_step = 0
  max_step = 200
  step_size = 50
  first_learning_depth = df_summary[df_summary$seed == seed,]$first_learning_depth
  for(step in seq(min_step, max_step, step_size)){
    if(first_learning_depth > step){
      slurm_replay_str = paste0(slurm_replay_str, first_learning_depth - step)
      if(step != max_step){
        slurm_replay_str = paste0(slurm_replay_str, ' ')
      }
    }
  }
  
  slurm_replay_str = paste0(slurm_replay_str, '"\n')
}
cat(slurm_replay_str)
