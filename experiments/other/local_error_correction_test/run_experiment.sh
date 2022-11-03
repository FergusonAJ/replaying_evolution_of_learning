#!/bin/bash

for ANCESTOR in handcoded_learner evolved_learner error_correction bet_hedged_learning
do
  for EXIT_COOLDOWN in 0 1 2 3 4 5 10 20 30 40 50 75 100 150 200
  do
    ./MABE -f ../settings/EvalDoors/3c1s/shared_config.mabe ../settings/EvalDoors/3c1s/analysis.mabe -s avida_org.initial_genome_filename=\"../settings/EvalDoors/3c1s/${ANCESTOR}.org\" -s eval_doors.exit_cooldown=${EXIT_COOLDOWN}
    mv single_org_fitness.csv error_correction_data/${ANCESTOR}_${EXIT_COOLDOWN}.csv
  done
done
