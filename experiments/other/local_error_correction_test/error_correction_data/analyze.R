rm(list = ls())

library(ggplot2)
library(dplyr)

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

plot_dir = './plots'
if(!dir.exists(plot_dir)){
  dir.create(plot_dir)
}

ggplot(df, aes(x = as.factor(exit_cooldown), y = merit, fill = as.factor(ancestor_str))) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism')
ggsave(paste0(plot_dir, '/exit_cooldown__all.png'), width = 8, height = 6, units = 'in')

ggplot(df[df$ancestor_str %in% c('Error correction', 'Learning (evolved)', 'Learning (handcoded)'),], aes(x = as.factor(exit_cooldown), y = merit, fill = as.factor(ancestor_str))) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism')
ggsave(paste0(plot_dir, '/exit_cooldown__lh_le_ec.png'), width = 8, height = 6, units = 'in')

ggplot(df[df$ancestor_str %in% c('Learning (evolved)', 'Learning (handcoded)'),], aes(x = as.factor(exit_cooldown), y = merit, fill = as.factor(ancestor_str))) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism')
ggsave(paste0(plot_dir, '/exit_cooldown__lh_le.png'), width = 8, height = 6, units = 'in')

ggplot(df[df$ancestor_str %in% c('Learning (handcoded)'),], aes(x = as.factor(exit_cooldown), y = merit, fill = as.factor(ancestor_str))) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 175)) +
  scale_fill_manual(values = color_map) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism')
ggsave(paste0(plot_dir, '/exit_cooldown__lh.png'), width = 8, height = 6, units = 'in')


df_grouped = dplyr::group_by(df, ancestor_str, exit_cooldown)
df_summary = dplyr::summarize(df_grouped, merit_mean = mean(merit), merit_median = median(merit), merit_max = max(merit), merit_min = min(merit), count = dplyr::n())

ggplot(df_summary, aes(x = exit_cooldown)) + 
  geom_ribbon(aes(ymin = merit_min, ymax = merit_max, fill = ancestor_str), alpha = 0.2) +
  geom_line(aes(y = merit_mean, color = ancestor_str)) +
  geom_line(aes(y = merit_median, color = ancestor_str), linetype = 'dashed') +
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(0, 175)) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism') +
  labs(color = 'Organism')
ggsave(paste0(plot_dir, '/exit_cooldown__line_all.png'), width = 8, height = 6, units = 'in')

ggplot(df_summary[df_summary$ancestor_str %in% c('Error correction', 'Learning (evolved)', 'Learning (handcoded)'),], aes(x = exit_cooldown)) + 
  geom_ribbon(aes(ymin = merit_min, ymax = merit_max, fill = ancestor_str), alpha = 0.2) +
  geom_line(aes(y = merit_mean, color = ancestor_str)) +
  geom_line(aes(y = merit_median, color = ancestor_str), linetype = 'dashed') +
  scale_color_manual(values = color_map) + 
  scale_fill_manual(values = color_map) + 
  scale_y_continuous(limits = c(0, 175)) +
  ylab('Merit') + 
  xlab('Exit cooldown') +
  labs(fill = 'Organism') +
  labs(color = 'Organism')
ggsave(paste0(plot_dir, '/exit_cooldown__line_lh_le_ec.png'), width = 8, height = 6, units = 'in')
                     