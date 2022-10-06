#!/bin/bash

../../../../MABE2/build/MABE -f shared_config.mabe analysis.mabe -s random_seed=1 -s avida_org.initial_genome_filename=\"ancestor.org\" -s avida_org.inst_set_input_filename=\"inst_set_input.txt\"
