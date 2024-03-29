rm(list = ls())

library(ggplot2)
library(Hmisc)

# Local include
source('./local_setup.R')

df_replay_classification_summary = load_targeted_replay_classification_summary()

alpha = 0.01

df_replay_classification_summary$wilson_lower = 
  Hmisc::binconf(df_replay_classification_summary$frac*50, 50, alpha=alpha, method='wilson')[,2]
df_replay_classification_summary$wilson_upper = 
  Hmisc::binconf(df_replay_classification_summary$frac*50, 50, alpha=alpha, method='wilson')[,3]

replay_plot_dir = paste0(plot_dir, 'targeted_replays/')
create_dir_if_needed(replay_plot_dir)

# Learning frac over time
ggplot(df_replay_classification_summary[df_replay_classification_summary$is_learning == T,], aes(x=target_window_depth, group = as.factor(seed))) + 
  geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
  geom_line(mapping=aes(y = frac), size = 1.05) + 
  geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(-0.1,1)) +
  xlab('Depth relative to start of target window') +
  ylab('Fraction of replicates that evolved learning') + 
  labs(color = 'Classification') +
  labs(fill = 'Classification')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time.png'), width = 9, height = 6, units = 'in')

# Learning frac with wilson confidence interval
ggplot(df_replay_classification_summary[df_replay_classification_summary$is_learning == T,], aes(x=target_window_depth, group = as.factor(seed))) + 
  geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
  geom_ribbon(mapping=aes(ymin=wilson_lower, ymax=wilson_upper), fill = '#aa3399', alpha = 0.2) +
  geom_line(mapping=aes(y = frac), size = 1.05) + 
  geom_point(mapping=aes(y = frac, color =  as.factor(lineage_classification)), size = 2.5) + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(-0.1,1)) +
  xlab('Depth relative to start of target window') +
  ylab('Fraction of replicates that evolved learning') + 
  labs(color = 'Classification') +
  labs(fill = 'Classification')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_wilson_conf.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_wilson_conf.png'), width = 9, height = 6, units = 'in')

# Learning frac over time - faceted 
ggplot(df_replay_classification_summary[df_replay_classification_summary$is_learning == T,], aes(x=target_window_depth, group = as.factor(seed))) + 
  geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
  geom_line(mapping=aes(y = frac), size = 1.05) + 
  geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(-0.1,1)) +
  xlab('Depth relative to start of target window') +
  ylab('Fraction of replicates that evolved learning') + 
  labs(color = 'Classification') +
  labs(fill = 'Classification') + 
  facet_wrap(vars(seed)) 
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_facet.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_facet.png'), width = 9, height = 6, units = 'in')

# Learning frac over time - faceted with wilson confidence interval
ggplot(df_replay_classification_summary[df_replay_classification_summary$is_learning == T,], aes(x=target_window_depth, group = as.factor(seed))) + 
  geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
  geom_ribbon(mapping=aes(ymin=wilson_lower, ymax=wilson_upper), fill = '#aa3399', alpha = 0.2) +
  geom_line(mapping=aes(y = frac), size = 1.05) + 
  geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(-0.1,1)) +
  xlab('Depth relative to start of target window') +
  ylab('Fraction of replicates that evolved learning') + 
  labs(color = 'Classification') +
  labs(fill = 'Classification') + 
  facet_wrap(vars(seed)) 
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_wilson_conf_facet.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_wilson_conf_facet.png'), width = 9, height = 6, units = 'in')

# Learning frac over time - faceted with wilson confidence interval
ggplot(df_replay_classification_summary[df_replay_classification_summary$is_learning == T,], aes(x=target_window_depth, group = as.factor(seed))) + 
  geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
  geom_errorbar(mapping=aes(ymin=wilson_lower, ymax=wilson_upper)) +
  geom_line(mapping=aes(y = frac), size = 1.05) + 
  geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(-0.0001,1.00001)) +
  xlab('Depth relative to start of target window') +
  ylab('Fraction of replicates that evolved learning') + 
  labs(color = 'Classification') +
  labs(fill = 'Classification') + 
  facet_wrap(vars(seed)) 
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_wilson_conf_bars_facet.pdf'), width = 9, height = 6, units = 'in')
ggsave(paste0(replay_plot_dir, '/learning_frac_over_time_wilson_conf_bars_facet.png'), width = 9, height = 6, units = 'in')

# Learning frac over time - faceted with wilson confidence interval
ggplot(df_replay_classification_summary[df_replay_classification_summary$is_learning == T,], aes(x=target_window_depth, group = as.factor(seed))) + 
  geom_hline(aes(yintercept = exploratory_replay_cutoff), linetype = 'dashed', alpha = 0.5) + 
  geom_errorbar(mapping=aes(ymin=wilson_lower, ymax=wilson_upper)) +
  #geom_line(mapping=aes(y = frac), size = 1.05) + 
  geom_point(mapping=aes(y = frac, color = as.factor(lineage_classification)), size = 2.5) + 
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(-0.0001,1.00001)) +
  xlab('Depth relative to start of target window') +
  ylab('Fraction of replicates that evolved learning') + 
  labs(color = 'Classification') +
  labs(fill = 'Classification') + 
  facet_wrap(vars(seed)) 

#   
# plot_each_depth = F
#   plot_depth_counts = T
#   if(plot_depth_counts){
#     df_depth_counts = dplyr::summarize(dplyr::group_by(classification_summary, depth), count = sum(count)) 
#     ggplot(df_depth_counts, aes(x = depth, y = count)) +
#       geom_line()
#     
#     ggplot(df_depth_counts[df_depth_counts$depth > 0,], aes(x = depth, y = count)) +
#       geom_line()
#     
#     max_nonzero_count = max(df_depth_counts[df_depth_counts$depth > 0,]$count)
#     print(df_depth_counts[df_depth_counts$count != max_nonzero_count,])
#     write.csv(df_depth_counts[df_depth_counts$count != max_nonzero_count,], paste0(replay_base_dir, '/missing_seeds.csv'))
#     cat('Missing seed info saved to: ', paste0(replay_base_dir, '/missing_seeds.csv'), '\n')
#     
#     #count_allowance = 2
#     #df_depth_counts = df_depth_counts[df_depth_counts$count >= max_nonzero_count - count_allowance,]
#     #print('Preparing to remove depths due to insufficient data: ')
#     #print(sort(unique(classification_summary[!(classification_summary$depth %in% df_depth_counts$depth),]$depth)))
#     #classification_summary = classification_summary[classification_summary$depth %in% df_depth_counts$depth,]
#   }
#   # Area plots
#   if(T){ 
#     # Area - Counts - All
#     ggplot(classification_summary, aes(x = depth, y = count, fill = seed_classification_factor)) +
#       geom_area() +
#       xlab('Phylogenetic depth') +
#       ylab('Number of replicates') + 
#       scale_fill_manual(values = color_map) +
#       labs(fill = 'Classification') + 
#       scale_x_continuous(expand = c(0,0)) +
#       scale_y_continuous(expand = c(0,0))
#     ggsave(paste0(plot_dir_all, '/replay_counts.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/replay_counts.png'), width = 9, height = 6, units = 'in')
#     
#     # Area - Fracs - All
#     ggplot(classification_summary, aes(x = depth, y = frac, fill = seed_classification_factor)) +
#       geom_area() +
#       scale_fill_manual(values = color_map) + 
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(fill = 'Classification') + 
#       scale_x_continuous(expand = c(0,0)) +
#       scale_y_continuous(expand = c(0,0))
#     ggsave(paste0(plot_dir_all, '/replay_fracs.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/replay_fracs.png'), width = 9, height = 6, units = 'in')
#     
#     ## Area - Fracs - Focal
#     #ggplot(classification_summary[mask_focal,], aes(x = depth, y = frac, fill = seed_classification_factor)) +
#     #  geom_area() +
#     #  scale_fill_manual(values = color_map) + 
#     #  xlab('Phylogenetic depth') +
#     #  ylab('Fraction of replicates') + 
#     #  labs(fill = 'Classification') + 
#     #  scale_x_continuous(expand = c(0,0)) +
#     #  scale_y_continuous(expand = c(0,0))
#     #ggsave(paste0(plot_dir_focal, '/replay_fracs__focal.pdf'), width = 9, height = 6, units = 'in')
#     #ggsave(paste0(plot_dir_focal, '/replay_fracs__focal.png'), width = 9, height = 6, units = 'in')
#     
#     # Area - Fracs - Initial
#     ggplot(classification_summary[mask_initial,], aes(x = depth, y = frac, fill = seed_classification_factor)) +
#       geom_area() +
#       scale_fill_manual(values = color_map) + 
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(fill = 'Classification') + 
#       scale_x_continuous(expand = c(0,0)) +
#       scale_y_continuous(expand = c(0,0))
#     ggsave(paste0(plot_dir_initial, '/replay_fracs__focal.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_initial, '/replay_fracs__focal.png'), width = 9, height = 6, units = 'in')
#   }
#   # Plot classification at each depth?
#   if(plot_each_depth){
#     for(depth in unique(classification_summary$depth)){
#       ggplot(classification_summary[classification_summary$depth == depth,], aes(x = seed_classification_factor, y = count, fill = seed_classification_factor)) + 
#         geom_col() + 
#         geom_text(aes(y = count + 3, label = count)) + 
#         scale_fill_manual(values = color_map) + 
#         xlab('Classification') + 
#         ylab('Number of replicates') + 
#         theme(legend.position = 'none')
#       ggsave(paste0(plot_dir_depths, '/classification_depth_', depth, '.pdf'), width = 9, height = 6, units = 'in')
#       ggsave(paste0(plot_dir_depths, '/classification_depth_', depth, '.png'), width = 9, height = 6, units = 'in')
#     }
#   }
#   # Classification over time line plots
#   if(T){
#     # Classification over time - Counts - All
#     ggplot(classification_summary, aes(x=depth, y = count, color = seed_classification_factor)) + 
#       geom_line(size=1.2) + 
#       geom_point(size = 2) + 
#       scale_color_manual(values = color_map) + 
#       xlab('Phylogenetic depth') +
#       ylab('Number of replicates') + 
#       labs(color = 'Classification')
#     ggsave(paste0(plot_dir_all, '/classification_counts_over_time.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/classification_counts_over_time.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time - Fracs - All
#     ggplot(classification_summary, aes(x=depth, y = frac, color = seed_classification_factor)) + 
#       geom_line(size=1.2) + 
#       geom_point(size = 2) + 
#       scale_color_manual(values = color_map) + 
#       scale_y_continuous(limits = c(0,1)) +
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(color = 'Classification')
#     ggsave(paste0(plot_dir_all, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time - Fracs - Focal
#     #ggplot(classification_summary[mask_focal,], aes(x=depth, y = frac, color = seed_classification_factor)) + 
#     #  geom_line(size=1.2) + 
#     #  geom_point(size = 2) + 
#     #  scale_color_manual(values = color_map) + 
#     #  scale_y_continuous(limits = c(0,1)) +
#     #  xlab('Phylogenetic depth') +
#     #  ylab('Fraction of replicates') + 
#     #  labs(color = 'Classification')
#     #ggsave(paste0(plot_dir_focal, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
#     #ggsave(paste0(plot_dir_focal, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time - Fracs - Initial
#     ggplot(classification_summary[mask_initial,], aes(x=depth, y = frac, color = seed_classification_factor)) + 
#       geom_line(size=1.2) + 
#       geom_point(size = 2) + 
#       scale_color_manual(values = color_map) + 
#       scale_y_continuous(limits = c(0,1)) +
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(color = 'Classification')
#     ggsave(paste0(plot_dir_initial, '/classification_frac_over_time.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_initial, '/classification_frac_over_time.png'), width = 9, height = 6, units = 'in')
#     
#   }
#   # Classification over time line plots with lineage data, if available
#   if(is.data.frame(df_lineage)){ 
#     # Classification over time w/ lineage data - Counts - All
#     ggplot(classification_summary, aes(x=depth, y = count, color = seed_classification_factor)) + 
#       geom_line(size=1.2) + 
#       geom_point(size = 2) + 
#       geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -15,ymax = -10, fill = seed_classification_factor), size = 0.1) +
#       scale_color_manual(values = color_map) + 
#       scale_fill_manual(values = color_map) + 
#       xlab('Phylogenetic depth') +
#       ylab('Number of replicates') + 
#       labs(color = 'Classification') +
#       labs(fill = 'Classification')
#     ggsave(paste0(plot_dir_all, '/classifications_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/classifications_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time w/ lineage data - Fracs - All
#     ggplot(classification_summary, aes(x=depth, color = seed_classification_factor)) + 
#       geom_line(mapping=aes(y = frac), size=1.2) + 
#       geom_point(mapping=aes(y = frac), size = 2) + 
#       #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
#       geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
#       scale_color_manual(values = color_map) + 
#       scale_fill_manual(values = color_map) + 
#       scale_y_continuous(limits = c(-0.1,1)) +
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(color = 'Classification') +
#       labs(fill = 'Classification')
#     ggsave(paste0(plot_dir_all, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time w/ lineage data - Fracs - Focal
#     #mask_focal_lineage = df_lineage$depth >= focal_start & df_lineage$depth <= focal_stop
#     #ggplot(classification_summary[mask_focal,], aes(x=depth, color = seed_classification_factor)) + 
#     #  geom_line(mapping=aes(y = frac), size=1.2) + 
#     #  geom_point(mapping=aes(y = frac), size = 2) + 
#     #  #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
#     #  geom_rect(data=df_lineage[mask_focal_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
#     #  scale_color_manual(values = color_map) + 
#     #  scale_fill_manual(values = color_map) + 
#     #  scale_y_continuous(limits = c(-0.1,1)) +
#     #  xlab('Phylogenetic depth') +
#     #  ylab('Fraction of replicates') + 
#     #  labs(color = 'Classification') +
#     #  labs(fill = 'Classification')
#     #ggsave(paste0(plot_dir_focal, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     #ggsave(paste0(plot_dir_focal, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time w/ lineage data - Fracs - Initial
#     ggplot(classification_summary[mask_initial,], aes(x=depth, color = seed_classification_factor)) + 
#       geom_line(mapping=aes(y = frac), size=1.2) + 
#       geom_point(mapping=aes(y = frac), size = 2) + 
#       #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
#       geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
#       scale_color_manual(values = color_map) + 
#       scale_fill_manual(values = color_map) + 
#       scale_y_continuous(limits = c(-0.1,1)) +
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(color = 'Classification') +
#       labs(fill = 'Classification')
#     ggsave(paste0(plot_dir_initial, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_initial, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#   }
#   # Classification over time line plots with lineage data, if available
#   if(is.data.frame(df_lineage)){ 
#     # Classification over time w/ lineage data - Counts - All
#     ggplot(classification_summary, aes(x=depth, y = count, color = seed_classification_factor)) + 
#       geom_line(size=1.2) + 
#       geom_point(size = 2) + 
#       geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -15,ymax = -10, fill = seed_classification_factor), size = 0.1) +
#       scale_color_manual(values = color_map) + 
#       scale_fill_manual(values = color_map) + 
#       xlab('Phylogenetic depth') +
#       ylab('Number of replicates') + 
#       labs(color = 'Classification') +
#       labs(fill = 'Classification')
#     ggsave(paste0(plot_dir_all, '/classifications_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/classifications_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time w/ lineage data - Fracs - All
#     ggplot(classification_summary, aes(x=depth, color = seed_classification_factor)) + 
#       geom_line(mapping=aes(y = frac), size=1.2) + 
#       geom_point(mapping=aes(y = frac), size = 2) + 
#       #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
#       geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
#       scale_color_manual(values = color_map) + 
#       scale_fill_manual(values = color_map) + 
#       scale_y_continuous(limits = c(-0.1,1)) +
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(color = 'Classification') +
#       labs(fill = 'Classification')
#     ggsave(paste0(plot_dir_all, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time w/ lineage data - Fracs - Focal
#     #mask_focal_lineage = df_lineage$depth >= focal_start & df_lineage$depth <= focal_stop
#     #ggplot(classification_summary[mask_focal,], aes(x=depth, color = seed_classification_factor)) + 
#     #  geom_line(mapping=aes(y = frac), size=1.2) + 
#     #  geom_point(mapping=aes(y = frac), size = 2) + 
#     #  #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
#     #  geom_rect(data=df_lineage[mask_focal_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
#     #  scale_color_manual(values = color_map) + 
#     #  scale_fill_manual(values = color_map) + 
#     #  scale_y_continuous(limits = c(-0.1,1)) +
#     #  xlab('Phylogenetic depth') +
#     #  ylab('Fraction of replicates') + 
#     #  labs(color = 'Classification') +
#     #  labs(fill = 'Classification')
#     #ggsave(paste0(plot_dir_focal, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     #ggsave(paste0(plot_dir_focal, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#     
#     # Classification over time w/ lineage data - Fracs - Initial
#     ggplot(classification_summary[mask_initial,], aes(x=depth, color = seed_classification_factor)) + 
#       geom_line(mapping=aes(y = frac), size=1.2) + 
#       geom_point(mapping=aes(y = frac), size = 2) + 
#       #geom_point(data=df_lineage, mapping = aes(x = depth, y = 205, color = seed_classification_factor), size = 0.1) +
#       geom_rect(data=df_lineage[df_lineage$depth <= max(classification_summary$depth),], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
#       scale_color_manual(values = color_map) + 
#       scale_fill_manual(values = color_map) + 
#       scale_y_continuous(limits = c(-0.1,1)) +
#       xlab('Phylogenetic depth') +
#       ylab('Fraction of replicates') + 
#       labs(color = 'Classification') +
#       labs(fill = 'Classification')
#     ggsave(paste0(plot_dir_initial, '/classification_frac_over_time_with_lineage.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_initial, '/classification_frac_over_time_with_lineage.png'), width = 9, height = 6, units = 'in')
#   }
#   # Learning diffs (no initial)
#   if(T){
#     # Calculate the increasing in learning from each time step
#     learning_mask = classification_summary$seed_classification == seed_class_learning
#     learning_classification_summary = classification_summary[learning_mask,]
#     learning_depths = unique(learning_classification_summary$depth)
#     df_learning_diffs = data.frame(data = matrix(nrow = 0, ncol = 8))
#     colnames(df_learning_diffs) = c('start_depth', 'finish_depth', 'start_reps', 'finish_reps', 'diff', 'start_frac', 'finish_frac', 'diff_frac')
#     for(depth in learning_depths){
#       if(depth == max(learning_depths)){
#         next
#       }
#       start_depth = depth
#       finish_depth = min(learning_depths[learning_depths > depth])
#       start_learning_reps = learning_classification_summary[learning_classification_summary$depth == start_depth,]$count
#       finish_learning_reps = learning_classification_summary[learning_classification_summary$depth == finish_depth,]$count
#       diff = finish_learning_reps - start_learning_reps
#       start_frac = learning_classification_summary[learning_classification_summary$depth == start_depth,]$frac
#       finish_frac = learning_classification_summary[learning_classification_summary$depth == finish_depth,]$frac
#       diff_frac = finish_frac - start_frac
#       df_learning_diffs[nrow(df_learning_diffs) +1,] = c(start_depth, finish_depth, start_learning_reps, finish_learning_reps, diff, start_frac, finish_frac, diff_frac)
#     }
#     # Create masks
#     #mask_learning_diff_focal = df_learning_diffs$start_depth %in% focal_start:focal_stop
#     
#     # Learning diff line plot - All
#     ggplot(df_learning_diffs, aes(x = start_depth, y = diff_frac)) + 
#       geom_line(size = 1.01) + 
#       geom_point(size = 2) + 
#       geom_text(aes(y = diff_frac + 0.1, label = round(diff_frac, 2)))+
#       geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) + 
#       ylab('Difference (in fraction of reps.)') +
#       xlab('Depth')
#     ggsave(paste0(plot_dir_all, '/learning_diff_frac_lines.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/learning_diff_frac_lines.png'), width = 9, height = 6, units = 'in')
#     
#     ## Learning diff line plot - Focal
#     #ggplot(df_learning_diffs[mask_learning_diff_focal,], aes(x = start_depth, y = diff_frac)) + 
#     #  geom_line(size = 1.01) + 
#     #  geom_point(size = 2) + 
#     #  geom_text(aes(y = diff_frac + 0.1, label = round(diff_frac, 2)))+
#     #  geom_hline(aes(yintercept = 0), linetype = 'dashed', alpha = 0.5) +
#     #  ylab('Difference (in fraction of reps.)') +
#     #  xlab('Depth')
#     #ggsave(paste0(plot_dir_focal, '/learning_diff_frac_lines.pdf'), width = 9, height = 6, units = 'in')
#     #ggsave(paste0(plot_dir_focal, '/learning_diff_frac_lines.png'), width = 9, height = 6, units = 'in')
#     
#     # Learning diff histogram - All
#     ggplot(df_learning_diffs, aes(x = diff_frac)) + 
#       geom_histogram(binwidth = 0.05) + 
#       geom_vline(aes(xintercept=0)) + 
#       xlab('Difference (in fraction of replicates)') + 
#       ylab('Count')
#     ggsave(paste0(plot_dir_all, '/learning_diff_frac_histogram.pdf'), width = 9, height = 6, units = 'in')
#     ggsave(paste0(plot_dir_all, '/learning_diff_frac_histogram.png'), width = 9, height = 6, units = 'in')
#     
#     ## Learning diff histogram - Focal
#     #ggplot(df_learning_diffs[mask_learning_diff_focal,], aes(x = diff_frac)) + 
#     #  geom_histogram(binwidth = 0.05) + 
#     #  geom_vline(aes(xintercept=0)) + 
#     #  xlab('Difference (in fraction of replicates)') + 
#     #  ylab('Count')
#     #ggsave(paste0(plot_dir_focal, '/learning_diff_frac_histogram.pdf'), width = 9, height = 6, units = 'in')
#     #ggsave(paste0(plot_dir_focal, '/learning_diff_frac_histogram.png'), width = 9, height = 6, units = 'in')
#     
#     if(is.data.frame(df_lineage)){
#       df_learning_diffs$merit_diff = NA
#       df_learning_diffs$merit_quotient = NA
#       df_learning_diffs$start_merit_mean = NA
#       df_learning_diffs$finish_merit_mean = NA
#       for(depth in learning_depths){
#         if(depth == max(learning_depths)){
#           next
#         }
#         start_depth = depth
#         finish_depth = min(learning_depths[learning_depths > depth])
#         start_merit = df_lineage[df_lineage$depth == start_depth,]$merit_mean
#         finish_merit = df_lineage[df_lineage$depth == finish_depth,]$merit_mean
#         diff = finish_merit - start_merit
#         quotient = NA
#         if(start_merit != 0){
#           quotient = finish_merit / start_merit
#         }
#         df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$merit_diff = diff
#         df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$merit_quotient = quotient
#         df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$start_merit_mean = start_merit
#         df_learning_diffs[df_learning_diffs$start_depth == start_depth,]$finish_merit_mean = finish_merit
#       }
#     }
#     #ggplot(df_learning_diffs[mask_learning_diff_focal & df_learning_diffs$start_depth != focal_stop,], aes(x = diff_frac, y = merit_quotient)) + 
#     #  geom_hline(aes(yintercept=1), alpha = 0.5) +
#     #  geom_vline(aes(xintercept=0), alpha = 0.5) +
#     #  geom_point(alpha = 0.5) 
#     #ggplot(df_learning_diffs[mask_learning_diff_focal & df_learning_diffs$start_depth != focal_stop,], aes(x = diff_frac, y = merit_diff)) + 
#     #  geom_hline(aes(yintercept=0), alpha = 0.5) +
#     #  geom_vline(aes(xintercept=0), alpha = 0.5) +
#     #  geom_point(alpha = 0.5) 
#     ggplot(df_learning_diffs, aes(x = diff_frac, y = merit_quotient)) + 
#       geom_hline(aes(yintercept=1), alpha = 0.5) +
#       geom_vline(aes(xintercept=0), alpha = 0.5) +
#       geom_point(alpha = 0.5) +
#       scale_y_continuous(trans = 'log2')
#     ggplot(df_learning_diffs, aes(x = diff_frac, y = merit_diff)) + 
#       geom_hline(aes(yintercept=0), alpha = 0.5) +
#       geom_vline(aes(xintercept=0), alpha = 0.5) +
#       geom_point(alpha = 0.5)  + 
#       scale_y_continuous(trans = 'log2')
#     #ggplot(df_learning_diffs[mask_learning_diff_focal & df_learning_diffs$start_depth != focal_stop,], aes(x = start_depth, y = merit_quotient)) + 
#     #  geom_hline(aes(yintercept=1), alpha = 0.5) +
#     #  geom_line()
#     ggplot(df_learning_diffs[df_learning_diffs$start_depth > 0,], aes(x = start_depth, y = merit_quotient)) + 
#       geom_hline(aes(yintercept=1), alpha = 0.5) +
#       geom_line() +
#       scale_y_continuous(trans = 'log2')
#   }
