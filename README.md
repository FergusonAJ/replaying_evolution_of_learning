# Replaying the evolution of associative learning

This repository contains tools and data for an ongoing research project investigating the potentiation of associative learning along evolved lineages. 

We find it likely that multiple publications will come out of this work. To keep things coherent as projects build off each other, we'll keep all the files in this one repo. 


### Directory
While many subdirectories contain their own README files, here we provide an overview: 
- `/MABE2/` - Code for the Modular Agent Based Evolver 2, including the current (early) state of Avida5. 
- `/MABE2_extras/` - Various scripts (converters, visualizations, etc.) that work with data from MABE2.
- `/experiments/` - Setup and data for all experiments.
  - `/experiments/exploratory` - Exploratory studies that are not part of a particular publication.
  - `/experiments/alife_2023/` - The experiment featured in our ALife 2023 paper (see below).
- `/global_shared_files/` - Files that are shared across multiple experiments, analyses, etc. Just to reduce the number of files that get copied to each new experiment.
- `/supplement/` - Source code for the supplement website: https://fergusonaj.github.io/replaying_evolution_of_learning/index.html
- `/README.md` - This file.
- `/config_global.sh` - Configuration script used when running experiments.

## Publications

### Potentiating Mutations Facilitate the Evolution of Associative Learning in Digital Organisms"

__Link to publication:__ [In process]

__Venue__: ALife Conference 2023

__Experiment directory:__ `/experiments/alife_2023/2023_02_21_01__initial_10_cooldown`

__Direct supplement link:__ https://fergusonaj.github.io/replaying_evolution_of_learning/alife_2023/index.html

__Abstract:__ 
Scientists have long tried to predict evolutionary outcomes in order to design vaccines for next year's diseases, stabilize endangered ecosystems, or make better choices in designing evolutionary algorithms.  To predict, however, we must first be able to retroactively identify the key steps that determined the evolved state.  Researchers have long examined the role of historical contingency in evolution; when do small, seemingly insignificant mutations substantially shift the probabilities of what traits or behaviors ultimately evolve?  Practitioners of experimental evolution have recently begun to investigate this question using a new technique: analytic replay experiments.  We can found many populations with a given genotype in order to measure the probability of a particular trait evolving from that starting point; we call this the "potentiation" of that genotype.  Moving along a lineage, we can identify which mutations altered potentiation.  Here we used digital organisms to conduct a high-resolution analysis of how individual mutations affected the potentiation of associative learning. We find that the probability of evolving associative learning can increase suddenly -- even with a single mutation that appeared innocuous when it occurred.  While there was no obvious signal to identify potentiating mutations as they arose, we were able to retrospectively identify mechanisms by which these mutations influenced subsequent evolution.  Many of the most interesting and complex evolutionary adaptations that occur in nature are exceptionally rare.  Here, we extend techniques for understanding these rare evolutionary events and the patterns and processes that produce them.
