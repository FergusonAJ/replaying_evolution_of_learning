rm(list = ls())

library(ggplot2)

df = read.csv('../data/combined_df.csv')
df_summary = read.csv('../data/combined_df_summary.csv')
df_sim = read.csv('../data/sim_data.csv')


plot_dir = '../plots/'
if(!dir.exists(plot_dir)) dir.create(plot_dir, recursive = T, showWarnings = F)

plotted_classes = c('Learning', 'Error correction', 'Bet-hedged error correction', 'Bet-hedged imprinting')
score_factor_count = length(unique(df_sim$score_factor))
score_factor_width = max(df_sim$score) / (score_factor_count - 1)
score_factor_values = 0:score_factor_count * score_factor_width 
print(score_factor_values)
fill_map = c(
  '0' = '#303030',   
  '80' = '#c7e9c0',   
  '160' = '#a1d99b',   
  '240' = '#74c476',   
  '320' = '#31a354',   
  '400' = '#006d2c'
)

ggplot() + 
  geom_raster(data = df_sim, aes(x = correct_doors, y = incorrect_doors, fill = as.factor(score_factor))) + 
  geom_point(data = df_summary[df_summary$cues == '2c' & df_summary$seed_classification %in% plotted_classes,], aes(x = correct_doors_mean, y = incorrect_doors_mean), color = '#c430b0') + 
  facet_grid(cols = vars(error_step), rows = vars(seed_classification_factor)) +
  scale_x_continuous(expand = c(0,0)) + 
  scale_y_continuous(expand = c(0,0)) + 
  scale_fill_manual(values = fill_map) +
  ggtitle('2c summary')
ggsave(paste0(plot_dir, '/combined_2c_summary.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/combined_2c_summary.png'), width = 9, height = 6, units = 'in')

#seed = 87 
#df_lineage = read.csv(paste0('../../2022_09_28__2c_error_step_1_0/data/reps/', seed, '/dominant_lineage_summary.csv'))
#ggplot() + 
#  geom_raster(data = df_sim[df_sim$error_base == 1,], aes(x = correct_doors, y = incorrect_doors, fill = as.factor(score_factor))) + 
#  geom_point(data = df_lineage, aes(x = correct_doors_mean, y = incorrect_doors_mean, color = depth)) +
#  geom_line(data = df_lineage, aes(x = correct_doors_mean, y = incorrect_doors_mean, color = depth)) +
#  scale_x_continuous(expand = c(0,0)) + 
#  scale_y_continuous(expand = c(0,0)) + 
#  scale_fill_manual(values = fill_map) +
#  ggtitle(paste0('Seed: ', seed))

ggplot() + 
  geom_raster(data = df_sim, aes(x = correct_doors, y = incorrect_doors, fill = as.factor(score_factor))) + 
  geom_point(data = df_summary[df_summary$cues == '3c1s' & df_summary$seed_classification %in% plotted_classes,], aes(x = correct_doors_mean, y = incorrect_doors_mean), color = '#c430b0') + 
  facet_grid(cols = vars(error_step), rows = vars(seed_classification_factor)) +
  scale_x_continuous(expand = c(0,0)) + 
  scale_y_continuous(expand = c(0,0)) + 
  scale_fill_manual(values = fill_map) +
  ggtitle('3c1s summary')
ggsave(paste0(plot_dir, '/combined_3c1s_summary.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/combined_3c1s_summary.png'), width = 9, height = 6, units = 'in')

ggplot() + 
  geom_raster(data = df_sim, aes(x = correct_doors, y = incorrect_doors, fill = as.factor(score_factor))) + 
  geom_point(data = df[df$cues == '2c' & df$seed_classification %in% plotted_classes,], aes(x = correct_doors, y = incorrect_doors), color = '#c430b0', alpha=0.15) + 
  facet_grid(cols = vars(error_step), rows = vars(seed_classification_factor)) +
  scale_x_continuous(expand = c(0,0)) + 
  scale_y_continuous(expand = c(0,0)) + 
  scale_fill_manual(values = fill_map) +
  ggtitle('2c all points')
ggsave(paste0(plot_dir, '/combined_2c.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/combined_2c.png'), width = 9, height = 6, units = 'in')

ggplot() + 
  geom_raster(data = df_sim, aes(x = correct_doors, y = incorrect_doors, fill = as.factor(score_factor))) + 
  geom_point(data = df[df$cues == '3c1s' & df$seed_classification %in% plotted_classes,], aes(x = correct_doors, y = incorrect_doors), color = '#c430b0', alpha=0.15) + 
  facet_grid(cols = vars(error_step), rows = vars(seed_classification_factor)) +
  scale_x_continuous(expand = c(0,0)) + 
  scale_y_continuous(expand = c(0,0)) + 
  scale_fill_manual(values = fill_map) +
  ggtitle('3c1s all points')
ggsave(paste0(plot_dir, '/combined_3c1s.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(plot_dir, '/combined_3c1s.png'), width = 9, height = 6, units = 'in')
