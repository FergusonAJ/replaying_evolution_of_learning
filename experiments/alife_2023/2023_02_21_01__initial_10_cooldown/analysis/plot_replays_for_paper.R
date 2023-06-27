rm(list = ls())

library(ggplot2)
library(cowplot)
library(grid)
library(gridExtra)
source('../../../../global_shared_files/constant_vars__three_cues_one_set.R')
source('../../../../global_shared_files/shared_funcs__three_cues_one_set.R')

focal_start_map = c(
  '86' = 400,
  '4' = 50, 
  '15' = 250,
  '6' = 500
)
focal_stop_map = c(
  '86' = 500,
  '4' = 150,
  '15' = 300,
  '6' = 550
)
focal_target_map = c(
  '86' = 484,
  '4' = 104,
  '15' = 279,
  '6' = 548
)

df_4 = read.csv('../data/reps/4/replays/processed_data/processed_learning_summary.csv')
df_4$seed = 4
df_4$lineage_name = 'Lineage B'
df_6 = read.csv('../data/reps/6/replays/processed_data/processed_learning_summary.csv')
df_6$seed = 6
df_6$lineage_name = 'Lineage D'
df_15 = read.csv('../data/reps/15/replays/processed_data/processed_learning_summary.csv')
df_15$seed = 15
df_15$lineage_name = 'Lineage C'
df_86 = read.csv('../data/reps/86/replays/processed_data/processed_learning_summary.csv')
df_86$seed = 86
df_86$lineage_name = 'Lineage A'
df = rbind(df_4, df_6, df_15, df_86)

df$is_initial = df$depth %% 50 == 0
df$is_targeted = df$depth %% 50 != 0
df[df$seed == 86 & df$depth %in% c(400,450,500),]$is_targeted = T
df[df$seed == 4 & df$depth %in% c(50,100,150),]$is_targeted = T
df[df$seed == 6 & df$depth %in% c(500,550),]$is_targeted = T
df[df$seed == 15 & df$depth %in% c(250,300),]$is_targeted = T

mask_initial = df$is_initial
mask_targeted = df$is_targeted

margin_top = 0.2
point_size = 1.3
font_size_small = 12
font_size_large = 14
line_size = 0.7

ggplot(df, aes(x=depth)) + 
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = 2.5) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(legend.position = 'none') + 
      facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')

if(T){
  ggp_4_init = ggplot(df[mask_initial & df$seed == 4,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['4'], xmax=focal_stop_map['4'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
  ggp_4_target = ggplot(df[mask_targeted & df$seed == 4,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['4'], xmax=focal_stop_map['4'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      geom_vline(aes(xintercept = focal_target_map['4']), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
}
if(T){
  ggp_6_init = ggplot(df[mask_initial & df$seed == 6,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['6'], xmax=focal_stop_map['6'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
  ggp_6_target = ggplot(df[mask_targeted & df$seed == 6,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['6'], xmax=focal_stop_map['6'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      geom_vline(aes(xintercept = focal_target_map['6']), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
}
if(T){
  ggp_15_init = ggplot(df[mask_initial & df$seed == 15,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['15'], xmax=focal_stop_map['15'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
  ggp_15_target = ggplot(df[mask_targeted & df$seed == 15,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['15'], xmax=focal_stop_map['15'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      geom_vline(aes(xintercept = focal_target_map['15']), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
}
if(T){
  ggp_86_init = ggplot(df[mask_initial & df$seed == 86,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['86'], xmax=focal_stop_map['86'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      #geom_vline(aes(xintercept = focal_target), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map, breaks = c(seed_class_learning, seed_class_bet_hedged_learning, seed_class_error_correction, seed_class_bet_hedged_error_correction, seed_class_bet_hedged_mixed, seed_class_small)) + 
      scale_fill_manual(values = color_map, breaks = c(seed_class_learning, seed_class_bet_hedged_learning, seed_class_error_correction, seed_class_bet_hedged_error_correction, seed_class_bet_hedged_mixed, seed_class_small)) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top + 0.1,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
  ggp_86_target = ggplot(df[mask_targeted & df$seed == 86,], aes(x=depth)) + 
      annotate("rect", xmin=focal_start_map['86'], xmax=focal_stop_map['86'], ymin=-Inf, ymax=Inf, alpha=0.2, fill="#64e164") +
      geom_vline(aes(xintercept = focal_target_map['86']), linetype = 'dotted') +
      geom_line(mapping=aes(y = frac*100), size = line_size) + 
      geom_point(mapping=aes(y = frac*100, color = as.factor(lineage_classification)), size = point_size) + 
      #geom_rect(data=df_lineage[mask_initial_lineage,], mapping = aes(xmin = depth,xmax = depth+1, ymin = -0.075,ymax = -0.05, fill = seed_classification_factor), size = 0.1) +
      scale_color_manual(values = color_map) + 
      scale_fill_manual(values = color_map) + 
      scale_y_continuous(limits = c(-0.1,100)) +
      xlab('Phylogenetic step') +
      #ylab('Percentage of replicates') + 
      ylab('Percentage of replays that evolve learning') + 
      labs(color = 'Classification') +
      labs(fill = 'Classification') +
      theme(axis.text = element_text(size = font_size_small)) +
      theme(axis.title = element_text(size = font_size_large)) +
      theme(axis.title = element_blank()) +
      theme(plot.margin = unit(c(margin_top + 0.1,0.1,0,0), 'in')) +
      theme(legend.position = 'none')
      #facet_grid(rows = vars(lineage_name), cols = vars(is_initial), scales = 'free_x')
}


combined_plot = plot_grid(ggp_86_init, ggp_86_target, ggp_4_init, ggp_4_target, ggp_15_init, ggp_15_target, ggp_6_init, ggp_6_target, 
                          nrow = 4, ncol = 2, labels = c('Lineage A', '', 'Lineage B', '','Lineage C', '', 'Lineage D', ''), 
                          vjust = c(1.5,1,1,1,1,1,1,1))

# Adding shared axes: https://stackoverflow.com/a/50477585
y_grob <- textGrob("Percentage of replays that evolve learning", 
                   gp=gpar(fontsize=18), rot=90)

x_grob <- textGrob("Phylogenetic step", 
                   gp=gpar(fontsize=18))

axis_plot = arrangeGrob(combined_plot, left = y_grob, bottom = x_grob)

# Shared legend:  https://wilkelab.org/cowplot/articles/shared_legends.html
shared_legend <- get_legend(ggp_86_init + 
    #guides(color = guide_legend(nrow = 1)) +
    theme(legend.position = "bottom") + 
    theme(legend.title = element_text(size = font_size_large)) + 
    theme(legend.text = element_text(size = font_size_small)) +
    guides(fill=guide_legend(nrow=3)) +
    guides(color=guide_legend(nrow=3)) 
)
final_plot = plot_grid(axis_plot, shared_legend, nrow = 2, ncol = 1, rel_heights = c(0.9, 0.1))


ggsave(final_plot, filename = '../plots/combined_replays_R.png', units = 'in', width = 8, height = 11)
ggsave(final_plot, filename = '../plots/combined_replays_R.pdf', units = 'in', width = 8, height = 11)

