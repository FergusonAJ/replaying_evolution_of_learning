# Load libraries and local helper files
library(ggplot2)
library(dplyr)

# NOTE: This file expects that constant_vars__two_cues.R has already been sourced

plot_masked_data = function(data, mask, title){
  df_class = data.frame(data = matrix(ncol = 5, nrow = 0))
  colnames(df_class) = c('seed', 'trial_number', 'door_idx', 'num_taken', 'num_correct')
  for(row_idx in 1:sum(mask)){
    row = data[mask,][row_idx,] 
    df_class[nrow(df_class) + 1,] = c(row$seed, row$trial_number, 1, row$doors_taken_1, row$doors_correct_1)
    df_class[nrow(df_class) + 1,] = c(row$seed, row$trial_number, 2, row$doors_taken_2, row$doors_correct_2)
  }
  df_class$group = paste0(df_class$seed, 'x', df_class$trial_number)
  max_val = max(df_class$num_taken)
  ggp = ggplot(df_class) + 
    geom_abline(slope = 1, intercept = 0, linetype = 'dashed', alpha = 0.25) +
    geom_point(aes(x = num_taken, y = num_correct, shape = as.factor(door_idx), color = as.factor(door_idx)), alpha = 0.5) + 
    geom_line(aes(x = num_taken,y = num_correct, group = group), alpha = 0.1) +
    ggtitle(title) + 
    xlab('Doors taken') +
    ylab('Doors correct') +
    labs(shape = 'Door index') + 
    scale_x_continuous(limits=c(0,max_val)) +
    scale_y_continuous(limits=c(0,max_val))
  print(ggp)
}

classify_individual_trials = function(df){
  # Add helper columns
  df$doors_incorrect_0 = df$doors_taken_0 - df$doors_correct_0
  df$doors_incorrect_1 = df$doors_taken_1 - df$doors_correct_1
  df$doors_incorrect_2 = df$doors_taken_2 - df$doors_correct_2
  
  # Classify
  df$trial_classification = trial_class_none 
  df$trial_classification[df$trial_classification == trial_class_none & df$accuracy == 1] = trial_class_perfect
  df$trial_classification[df$trial_classification == trial_class_none & df$correct_doors < 25] = trial_class_small
  df$trial_classification[df$trial_classification == trial_class_none & df$accuracy == 0] = trial_class_zero
  df$trial_classification[df$trial_classification == trial_class_none & df$accuracy > 0.98 & df$incorrect_doors <= 1] = trial_class_learning_optimal
  df$trial_classification[df$trial_classification == trial_class_none & df$accuracy > 0.90 & df$incorrect_doors <= (df$correct_doors * 0.1)] = trial_class_learning_suboptimal
  df$trial_classification[df$trial_classification == trial_class_none & df$doors_incorrect_2 <= 1 & df$doors_incorrect_1 >= df$doors_correct_2 & df$doors_incorrect_1 <= (df$doors_correct_2 + 1)] = trial_class_error_correction_naive_1
  df$trial_classification[df$trial_classification == trial_class_none & df$doors_incorrect_1 <= 1 & df$doors_incorrect_2 >= df$doors_correct_1 & df$doors_incorrect_2 <= (df$doors_correct_1 + 1)] = trial_class_error_correction_naive_2
  df$trial_classification[df$trial_classification == trial_class_none & df$doors_incorrect_2 <= 1] = trial_class_error_correction_better_1
  df$trial_classification[df$trial_classification == trial_class_none & df$doors_incorrect_1 <= 1] = trial_class_error_correction_better_2
  #df$trial_classification[df$trial_classification == trial_class_none & df$doors_correct_0 >= df$doors_taken_0 - 1 & df$doors_incorrect_1 > 1 & df$doors_correct_1 > 0 & df$doors_incorrect_2 > 1 & df$doors_correct_2 > 0] = trial_class_error_correction_split
  df$trial_classification[df$trial_classification == trial_class_none & df$doors_incorrect_1 > 1 & df$doors_correct_1 > 0 & df$doors_incorrect_2 > 1 & df$doors_correct_2 > 0] = trial_class_error_correction_split
  df$trial_classification[df$correct_doors < 25] = trial_class_small
  df$trial_classification[df$df$incorrect_doors > 0 & df$doors_correct_0 == 0] = trial_class_trapped
  df$trial_classification[df$exit_rooms >= 2 * df$door_rooms] = trial_class_trapped
  return(df)
}

classify_seeds = function(df){
  df_tmp = tidyr::pivot_wider(df, names_from = trial_classification, values_from = trial_classification, values_fill = '0')
  df_tmp = as.data.frame(df_tmp)
  for(col_name in trial_classification_order_vec){
    if(!col_name %in% colnames(df_tmp)){
      df_tmp[,col_name] = '0'
    }
    df_tmp[df_tmp[,col_name] != '0', col_name] = '1'
    df_tmp[,col_name] = as.numeric(as.vector(df_tmp[,col_name])) 
  } 
  df_grouped = NA
  if('depth' %in% colnames(df_tmp)){
    df_grouped = dplyr::group_by(df_tmp, depth, seed)
  } else{
    df_grouped = dplyr::group_by(df_tmp, seed)
  }
  df_summary = dplyr::summarize(df_grouped, 
                                num_trials := dplyr::n(),
                                (!!rlang::sym(trial_class_none)) := sum(!! rlang::sym(trial_class_none)),
                                (!!rlang::sym(trial_class_perfect)) := sum(!! rlang::sym(trial_class_perfect)),
                                (!!rlang::sym(trial_class_zero)) := sum(!! rlang::sym(trial_class_zero)),
                                (!!rlang::sym(trial_class_learning_optimal)) := sum(!! rlang::sym(trial_class_learning_optimal)),
                                (!!rlang::sym(trial_class_learning_suboptimal)) := sum(!! rlang::sym(trial_class_learning_suboptimal)),
                                (!!rlang::sym(trial_class_error_correction_naive_1)) := sum(!! rlang::sym(trial_class_error_correction_naive_1)),
                                (!!rlang::sym(trial_class_error_correction_naive_2)) := sum(!! rlang::sym(trial_class_error_correction_naive_2)),
                                (!!rlang::sym(trial_class_error_correction_better_1)) := sum(!! rlang::sym(trial_class_error_correction_better_1)),
                                (!!rlang::sym(trial_class_error_correction_better_2)) := sum(!! rlang::sym(trial_class_error_correction_better_2)),
                                (!!rlang::sym(trial_class_error_correction_split)) := sum(!! rlang::sym(trial_class_error_correction_split)),
                                (!!rlang::sym(trial_class_trapped)) := sum(!!rlang::sym(trial_class_trapped)),
                                (!!rlang::sym(trial_class_small)) := sum(!! rlang::sym(trial_class_small)),
                                )
  # Create helper variables
  df_summary$all_learning = df_summary$learning_optimal + df_summary$learning_suboptimal + df_summary$perfect
  df_summary$all_error_correction = df_summary$naive_error_correction_lead_1 + df_summary$naive_error_correction_lead_2 + df_summary$better_error_correction_lead_1 + df_summary$better_error_correction_lead_2 + df_summary$split_error_correction
  df_summary$all_failed = df_summary$trapped + df_summary$small
  # Classify
  df_summary$seed_classification = seed_class_other
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$all_learning == df_summary$num_trials,]$seed_classification = seed_class_learning  
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$all_error_correction == df_summary$num_trials,]$seed_classification = seed_class_error_correction
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$all_learning > 0 & df_summary$all_learning + df_summary$all_failed == df_summary$num_trials,]$seed_classification = seed_class_bet_hedged_learning
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$all_error_correction > 0 & df_summary$all_error_correction + df_summary$all_failed == df_summary$num_trials,]$seed_classification = seed_class_bet_hedged_error_correction
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$all_error_correction > 0 & df_summary$all_learning > 0 & df_summary$all_error_correction + df_summary$all_learning + df_summary$all_failed == df_summary$num_trials,]$seed_classification = seed_class_bet_hedged_mixed
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$small > 0,]$seed_classification = seed_class_small
  df_summary[df_summary$seed_classification == seed_class_other & df_summary$all_failed == df_summary$num_trials,]$seed_classification = seed_class_small
  
  # Add seed classification to original data frame 
  df$seed_classification = seed_class_other
  if('depth' %in% colnames(df)){
    for(depth in unique(df_summary$depth)){
      summary_depth_mask = df_summary$depth == depth
      depth_mask = df$depth == depth
      for(seed in unique(df_summary[summary_depth_mask,]$seed)){
        df[depth_mask & df$seed == seed,]$seed_classification = df_summary[summary_depth_mask & df_summary$seed == seed,]$seed_classification
      }
    }
  } else{
    for(seed in unique(df_summary$seed)){
      df[df$seed == seed,]$seed_classification = df_summary[df_summary$seed == seed,]$seed_classification
    }
  }
  df$seed_classification_factor = factor(df$seed_classification, levels = seed_classifcation_order_vec)
  return(df)
}

summarize_final_dominant_org_data = function(df){
  if(!'seed_classification' %in% colnames(df)){
    df = classify_individual_trials(df)
    df = classify_seeds(df)
  }
  df_grouped = NA
  if('depth' %in% colnames(df)){
    df_grouped = dplyr::group_by(df, depth, seed)
  } else{
    df_grouped = dplyr::group_by(df, seed)
  }
  df_summary = dplyr::summarize(df_grouped, count = dplyr::n(), 
                                accuracy_mean = mean(accuracy), accuracy_max = max(accuracy), accuracy_min = min(accuracy),
                                merit_mean = mean(merit), merit_max = max(merit), merit_min = min(merit),
                                door_rooms_mean = mean(door_rooms), door_rooms_max = max(door_rooms), door_rooms_min = min(door_rooms),
                                exit_rooms_mean = mean(exit_rooms), exit_rooms_max = max(exit_rooms), exit_rooms_min = min(exit_rooms),
                                correct_doors_mean = mean(correct_doors), correct_doors_max = max(correct_doors), correct_doors_min = min(correct_doors),
                                incorrect_doors_mean = mean(incorrect_doors), incorrect_doors_max = max(incorrect_doors), incorrect_doors_min = min(incorrect_doors),
                                correct_exits_mean = mean(correct_exits), correct_exits_max = max(correct_exits), correct_exits_min = min(correct_exits),
                                incorrect_exits_mean = mean(incorrect_exits), incorrect_exits_max = max(incorrect_exits), incorrect_exits_min = min(incorrect_exits),
                                genome_length = mean(genome_length),
                                seed_classification = first(seed_classification)
  )
  df_summary$seed_classification_factor = factor(df_summary$seed_classification, levels = seed_classifcation_order_vec)
  return(df_summary)
}

summarize_classifications = function(df_summary){
  classification_grouped = NA
  if('depth' %in% colnames(df_summary)){
    classification_grouped = dplyr::group_by(df_summary, depth, seed_classification)
  }
  else{
    classification_grouped = dplyr::group_by(df_summary, seed_classification)
  }
  classification_summary = dplyr::summarize(classification_grouped, count = n(), accuracy_mean_mean = mean(accuracy_mean), merit_mean_mean = mean(merit_mean))
  classification_summary$seed_classification_factor = factor(classification_summary$seed_classification, levels = seed_classifcation_order_vec)
  return(classification_summary)
}