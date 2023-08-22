# Local include
source('./local_setup.R')

# Load data
df = load_exploratory_replay_classification_summary()

# Config options
replay_step = 50

slurm_replay_seed_str = 'REPLAY_SEEDS="'
slurm_replay_depth_str = ''
seed_vec = sort(unique(df$seed))

df$frac_diff = NA
df$next_frac_diff = NA
df$is_target_window_end = F
df$is_target_window_start = F
for(seed in seed_vec){
  # First, calculate the potemtiation gain at every point other than the first one
  seed_mask = df$seed == seed & df$is_learning
  min_depth = min(df[seed_mask,]$depth)
  for(depth in unique(df[seed_mask & df$depth != min_depth,]$depth)){
    old_frac = df[seed_mask & df$depth == depth - replay_step,]$frac
    new_frac = df[seed_mask & df$depth == depth,]$frac
    df[seed_mask & df$depth == depth,]$frac_diff = new_frac - old_frac
    df[seed_mask & df$depth == depth - replay_step,]$next_frac_diff = new_frac - old_frac
  }

  # Next, find the depth that confers the largest gain in potentiation  
  max_diff = max(df[seed_mask,]$frac_diff, na.rm = T)
  max_diff_depth = df[seed_mask & df$frac_diff == max_diff & !is.na(df$frac_diff),]$depth
  if(is.vector(max_diff_depth) & length(max_diff_depth) > 1){
    cat('Error! We have a tie for largest potentiation gain!\n')
    cat('Gain:', max_diff, '\n')
    cat('Depths:', max_diff_depth, '\n')
    cat('Exiting!\n')
    q()
  }
  # Make sure there aren't any similarly sized jumps next to this one
  start = max_diff_depth - replay_step
  start_row = df[seed_mask & df$depth == start,]
  while(!is.na(start_row$frac_diff) & start_row$frac_diff >= 0.1 & start_row$frac_diff >= max_diff - 0.1){
    start = start - replay_step
    start_row = df[seed_mask & df$depth == start,]
  }
  stop = max_diff_depth
  stop_row = df[seed_mask & df$depth == stop,]
  while(!is.na(stop_row$next_frac_diff) & stop_row$next_frac_diff >= 0.1 & stop_row$next_frac_diff >= max_diff - 0.1){
    stop = stop + replay_step
    stop_row = df[seed_mask & df$depth == stop,]
  }
  df[seed_mask & df$depth == start,]$is_target_window_start= T  
  df[seed_mask & df$depth == stop,]$is_target_window_end = T  
  
  # Add onto the seed list
  if(seed != seed_vec[1]){ # Not the first seed
    slurm_replay_seed_str = paste0(slurm_replay_seed_str, ' ')
  }
  slurm_replay_seed_str = paste0(slurm_replay_seed_str, seed)
  # Add entry to depth map 
  slurm_replay_depth_str = paste0(slurm_replay_depth_str, 'DEPTH_MAP[', seed, ']="')
  first_depth = T
  for(depth in seq(start, stop)){
    if(!(depth %in% df[seed_mask,]$depth)){
      if(!first_depth){
        slurm_replay_depth_str = paste0(slurm_replay_depth_str, ' ')
      } else {
        first_depth = F
      }
      slurm_replay_depth_str = paste0(slurm_replay_depth_str, depth)
    }
  }
  slurm_replay_depth_str = paste0(slurm_replay_depth_str, '"\n')
}

slurm_replay_str = paste0(slurm_replay_seed_str, '"\ndeclare -a DEPTH_MAP\n', slurm_replay_depth_str)
cat('\n\n')
cat(slurm_replay_str)

filename = get_target_window_replay_classification_summary_filename()
write.csv(df, filename, row.names = F)
cat('Saved file to', filename, '\n')
