rm(list = ls())

library(ggplot2)

seed = 57

filename = paste0('../data/reps/', seed, '/final_dominant_org_fitness.csv')
df = read.csv(filename)

ggplot(df, aes(x = trial_number)) + 
  geom_point(aes(y = doors_taken_0, color = '0', shape = 'taken')) +
  geom_point(aes(y = doors_correct_0, color = '0', shape = 'correct')) +
  geom_point(aes(y = doors_taken_1, color = '1', shape = 'taken')) +
  geom_point(aes(y = doors_correct_1, color = '1', shape = 'correct')) +
  geom_point(aes(y = doors_taken_2, color = '2', shape = 'taken')) +
  geom_point(aes(y = doors_correct_2, color = '2', shape = 'correct')) +
  ylab('Doors taken')

df$door_accuracy_0 = df$doors_correct_0 / df$doors_taken_0
df$door_accuracy_1 = df$doors_correct_1 / df$doors_taken_1
df$door_accuracy_2 = df$doors_correct_2 / df$doors_taken_2
df$doors_incorrect_0 = df$doors_taken_0 - df$doors_correct_0
df$doors_incorrect_1 = df$doors_taken_1 - df$doors_correct_1
df$doors_incorrect_2 = df$doors_taken_2 - df$doors_correct_2

ggplot(df, aes(x = trial_number)) + 
  geom_point(aes(y = doors_incorrect_0, color = '0')) +
  geom_point(aes(y = doors_incorrect_1, color = '1')) +
  geom_point(aes(y = doors_incorrect_2, color = '2')) +
  ylab('Doors incorrect')

ggplot(df, aes(x = trial_number)) + 
  geom_point(aes(y = door_accuracy_0, color = '0')) +
  geom_point(aes(y = door_accuracy_1, color = '1')) +
  geom_point(aes(y = door_accuracy_2, color = '2')) +
  ylab('Door accuracy')
