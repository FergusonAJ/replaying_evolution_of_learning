rm(list = ls())

library(ggplot2)
library(dplyr)
library(tidyr)

plot_dir = './plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir)
}

df = NA 
for(ancestor in c('error_correction', 'evolved_learner', 'handcoded_learner', 'bet_hedged_learning')){
  for(exit_cooldown in c(0,1,2,3,4,5,10,20,30,40,50,75,100,150,200)){
    # Error correction
    df_tmp = read.csv(paste0('./', ancestor, '_', exit_cooldown, '.csv'))
    df_tmp$exit_cooldown = exit_cooldown 
    df_tmp$ancestor = ancestor 
    if(!is.data.frame(df)){
      df = df_tmp
    } else {
      df = rbind(df, df_tmp)
    }
  }
}

df$ancestor_str = NA
df[df$ancestor == 'error_correction',]$ancestor_str = 'Error correction'
df[df$ancestor == 'bet_hedged_learning',]$ancestor_str = 'Bet-hedged imprinting'
df[df$ancestor == 'evolved_learner',]$ancestor_str = 'Learning (evolved)'
df[df$ancestor == 'handcoded_learner',]$ancestor_str = 'Learning (handcoded)'

color_map = c(
  'Learning (handcoded)' = '#e41a1c',
  'Learning (evolved)' = '#4daf4a',
  'Error correction' = '#377eb8',
  'Bet-hedged imprinting' = '#984ea3'
)


df$merit_0_01 = df$correct_doors - df$incorrect_exits - df$incorrect_doors * df$incorrect_doors * 0.01 
df$merit_0_02 = df$correct_doors - df$incorrect_exits - df$incorrect_doors * df$incorrect_doors * 0.02
df$merit_0_03 = df$correct_doors - df$incorrect_exits - df$incorrect_doors * df$incorrect_doors * 0.03
df$merit_0_04 = df$correct_doors - df$incorrect_exits - df$incorrect_doors * df$incorrect_doors * 0.04
df$merit_0_05 = df$correct_doors - df$incorrect_exits - df$incorrect_doors * df$incorrect_doors * 0.05
df$merit_0_1 =  df$correct_doors - df$incorrect_exits - df$incorrect_doors * df$incorrect_doors * 0.1
df[df$merit_0_01 < 0,]$merit_0_01 = 0
df[df$merit_0_02 < 0,]$merit_0_02 = 0
df[df$merit_0_03 < 0,]$merit_0_03 = 0
df[df$merit_0_04 < 0,]$merit_0_04 = 0
df[df$merit_0_05 < 0,]$merit_0_05 = 0
df[df$merit_0_1 < 0,]$merit_0_1 = 0

df_grouped = dplyr::group_by(df, ancestor_str)
df_summary = dplyr::summarize(df_grouped, merit_mean = mean(merit), 
                              merit_mean_0_01 = mean(merit_0_01), 
                              merit_mean_0_02 = mean(merit_0_02), 
                              merit_mean_0_03 = mean(merit_0_03), 
                              merit_mean_0_04 = mean(merit_0_04), 
                              merit_mean_0_05 = mean(merit_0_05), 
                              merit_mean_0_1 = mean(merit_0_1), 
                              count = dplyr::n())

ggplot(df, aes(fill = as.factor(ancestor_str))) +
  geom_boxplot(aes(x = as.factor(0), y = merit)) +
  geom_boxplot(aes(x = as.factor(0.01), y = merit_0_01)) +
  geom_boxplot(aes(x = as.factor(0.02), y = merit_0_02)) +
  geom_boxplot(aes(x = as.factor(0.03), y = merit_0_03)) +
  geom_boxplot(aes(x = as.factor(0.04), y = merit_0_04)) +
  geom_boxplot(aes(x = as.factor(0.05), y = merit_0_05)) +
  geom_boxplot(aes(x = as.factor(0.1), y = merit_0_1)) +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Error step') +
  labs(fill = 'Organism') 
  #facet_grid(rows = vars(ancestor))
ggsave(paste0(plot_dir, '/error_step__all.png'), width = 8, height = 6, units = 'in')

ggplot(df[df$ancestor_str %in% c('Learning (handcoded)', 'Learning (evolved)', 'Error correction'),], aes(fill = as.factor(ancestor_str))) +
  geom_boxplot(aes(x = as.factor(0), y = merit)) +
  geom_boxplot(aes(x = as.factor(0.01), y = merit_0_01)) +
  geom_boxplot(aes(x = as.factor(0.02), y = merit_0_02)) +
  geom_boxplot(aes(x = as.factor(0.03), y = merit_0_03)) +
  geom_boxplot(aes(x = as.factor(0.04), y = merit_0_04)) +
  geom_boxplot(aes(x = as.factor(0.05), y = merit_0_05)) +
  geom_boxplot(aes(x = as.factor(0.1), y = merit_0_1)) +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Error step') +
  labs(fill = 'Organism') 
  #facet_grid(rows = vars(ancestor))
ggsave(paste0(plot_dir, '/error_step__lh_le_ec.png'), width = 8, height = 6, units = 'in')

ggplot(df[df$ancestor_str %in% c('Learning (handcoded)', 'Learning (evolved)'),], aes(fill = as.factor(ancestor_str))) +
  geom_boxplot(aes(x = as.factor(0), y = merit)) +
  geom_boxplot(aes(x = as.factor(0.01), y = merit_0_01)) +
  geom_boxplot(aes(x = as.factor(0.02), y = merit_0_02)) +
  geom_boxplot(aes(x = as.factor(0.03), y = merit_0_03)) +
  geom_boxplot(aes(x = as.factor(0.04), y = merit_0_04)) +
  geom_boxplot(aes(x = as.factor(0.05), y = merit_0_05)) +
  geom_boxplot(aes(x = as.factor(0.1), y = merit_0_1)) +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Error step') +
  labs(fill = 'Organism') 
  #facet_grid(rows = vars(ancestor))
ggsave(paste0(plot_dir, '/error_step__lh_le.png'), width = 8, height = 6, units = 'in')

ggplot(df[df$ancestor_str %in% c('Learning (handcoded)'),], aes(fill = as.factor(ancestor_str))) +
  geom_boxplot(aes(x = as.factor(0), y = merit)) +
  geom_boxplot(aes(x = as.factor(0.01), y = merit_0_01)) +
  geom_boxplot(aes(x = as.factor(0.02), y = merit_0_02)) +
  geom_boxplot(aes(x = as.factor(0.03), y = merit_0_03)) +
  geom_boxplot(aes(x = as.factor(0.04), y = merit_0_04)) +
  geom_boxplot(aes(x = as.factor(0.05), y = merit_0_05)) +
  geom_boxplot(aes(x = as.factor(0.1), y = merit_0_1)) +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Error step') +
  labs(fill = 'Organism') 
  #facet_grid(rows = vars(ancestor))
ggsave(paste0(plot_dir, '/error_step__lh.png'), width = 8, height = 6, units = 'in')

df_summary_tall = tidyr::pivot_longer(df_summary, cols = starts_with('merit_mean'))

ggplot(df_summary) + 
  #geom_ribbon(aes(ymin = merit_min, ymax = merit_max, fill = ancestor_str), alpha = 0.2) +
  geom_point(data = df_summary, aes(x = 0, y = merit_mean, color = ancestor_str)) +
  geom_point(data = df_summary, aes(x = 0.01, y = merit_mean_0_01, color = ancestor_str)) +
  geom_point(data = df_summary, aes(x = 0.02, y = merit_mean_0_02, color = ancestor_str)) +
  geom_point(data = df_summary, aes(x = 0.03, y = merit_mean_0_03, color = ancestor_str)) +
  geom_point(data = df_summary, aes(x = 0.04, y = merit_mean_0_04, color = ancestor_str)) +
  geom_point(data = df_summary, aes(x = 0.05, y = merit_mean_0_05, color = ancestor_str)) +
  geom_point(data = df_summary, aes(x = 0.1, y = merit_mean_0_1, color = ancestor_str)) +
  #geom_line(aes(y = merit_median, color = ancestor_str), linetype = 'dashed') +
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(0, 175)) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism') +
  labs(color = 'Organism')
#ggsave(paste0(plot_dir, '/exit_cooldown__line_all.png'), width = 8, height = 6, units = 'in')

df_summary_tall$merit_type = df_summary_tall$name
df_summary_tall$error_step = NA
df_summary_tall[df_summary_tall$merit_type == 'merit_mean',]$error_step = 0
df_summary_tall[df_summary_tall$merit_type == 'merit_mean_0_01',]$error_step = 0.01
df_summary_tall[df_summary_tall$merit_type == 'merit_mean_0_02',]$error_step = 0.02
df_summary_tall[df_summary_tall$merit_type == 'merit_mean_0_03',]$error_step = 0.03
df_summary_tall[df_summary_tall$merit_type == 'merit_mean_0_04',]$error_step = 0.04
df_summary_tall[df_summary_tall$merit_type == 'merit_mean_0_05',]$error_step = 0.05
df_summary_tall[df_summary_tall$merit_type == 'merit_mean_0_1',]$error_step = 0.1
df_summary_tall[df_summary_tall$]
ggplot(df_summary_tall) + 
  geom_line(aes(x = error_step, y = value, color = ancestor_str)) +
  geom_point(aes(x = error_step, y = value, color = ancestor_str)) +
  #geom_line(aes(y = merit_median, color = ancestor_str), linetype = 'dashed') +
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(0, 175)) +
  ylab('Mean adjusted merit') + 
  xlab('Error step') +
  labs(fill = 'Organism') +
  labs(color = 'Organism')
ggsave(paste0(plot_dir, '/error_step__line_all.png'), width = 8, height = 6, units = 'in')
