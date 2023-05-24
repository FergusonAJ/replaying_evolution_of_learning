# Names given to the different behavior classifications for entire seeds
seed_class_learning = 'Learning'
seed_class_error_correction = 'Error correction'
seed_class_other = 'Other'
seed_class_small = 'Low activity'
seed_class_bet_hedged_learning = 'Bet-hedged learning'
seed_class_bet_hedged_error_correction = 'Bet-hedged error correction'
seed_class_bet_hedged_mixed = 'Mixed bet hedging'

# When we plot classifications, do so in this order:
seed_classifcation_order_vec = c(
  seed_class_learning, 
  seed_class_bet_hedged_learning, 
  seed_class_error_correction, 
  seed_class_bet_hedged_error_correction, 
  seed_class_bet_hedged_mixed, 
  seed_class_other, 
  seed_class_small)

# Seed classification color scheme for all plots
# Muted qualitative scheme from Paul Tor https://personal.sron.nl/~pault/
color_map = c( 
  'Error correction' = '#ee99aa',
  'Bet-hedged error correction' = '#994455',
  'Learning' = '#6699cc',
  'Bet-hedged learning' = '#004488',
  'Mixed bet hedging' = '#eecc66',
  #'Mixed bet hedging' = '#997700',
  'Other' = '#000000',
  'Low activity' = '#7c7c7c'
  #'Low activity' = '#eecc66'
)

# Names for individual trial classification
trial_class_none = 'none'
trial_class_perfect = 'perfect'
trial_class_zero = 'zero'
trial_class_set_wrong = 'set_wrong'
trial_class_learning_optimal = 'learning_optimal'
trial_class_learning_suboptimal = 'learning_suboptimal'
trial_class_error_correction_naive_2 = 'naive_error_correction_lead_2'
trial_class_error_correction_naive_3 = 'naive_error_correction_lead_3'
trial_class_error_correction_better_2 = 'better_error_correction_lead_2'
trial_class_error_correction_better_3 = 'better_error_correction_lead_3'
trial_class_error_correction_split = 'split_error_correction'
trial_class_trapped = 'trapped'
trial_class_small = 'small'

trial_classification_order_vec = c(
  trial_class_none,
  trial_class_perfect,
  trial_class_zero,
  trial_class_set_wrong,
  trial_class_learning_optimal,
  trial_class_learning_suboptimal,
  trial_class_error_correction_naive_2,
  trial_class_error_correction_naive_3,
  trial_class_error_correction_better_2,
  trial_class_error_correction_better_3,
  trial_class_error_correction_split,
  trial_class_trapped,
  trial_class_small
)
