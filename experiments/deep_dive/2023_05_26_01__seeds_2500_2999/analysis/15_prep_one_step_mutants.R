# Local include
source('./local_setup.R')

# Load data
df = load_targeted_replay_classification_summary()

slurm_replay_seed_str = 'FOCAL_SEEDS="'
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
    old_frac = df[seed_mask & df$depth == depth - 1,]$frac
    new_frac = df[seed_mask & df$depth == depth,]$frac
    df[seed_mask & df$depth == depth,]$frac_diff = new_frac - old_frac
    df[seed_mask & df$depth == depth - 1,]$next_frac_diff = new_frac - old_frac
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
  
  mut_depth = max_diff_depth - 1
  # Add onto the seed list
  if(seed != seed_vec[1]){ # Not the first seed
    slurm_replay_seed_str = paste0(slurm_replay_seed_str, ' ')
  }
  slurm_replay_seed_str = paste0(slurm_replay_seed_str, seed)
  # Add entry to depth map 
  slurm_replay_depth_str = paste0(slurm_replay_depth_str, 'DEPTH_MAP[', seed, ']="',mut_depth,'"\n')
}

slurm_replay_str = paste0(slurm_replay_seed_str, '"\ndeclare -a DEPTH_MAP\n', slurm_replay_depth_str)
cat('\n\n')
cat(slurm_replay_str)

