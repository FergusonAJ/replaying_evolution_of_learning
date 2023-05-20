While there are many files here, the main one (other than mutations) is `./scrape_final_dominant_data.sh`.
It will handle the main data of both the initial replicates and replays. 

## Directory
### Evolution 
- `./combine_final_dominant_data.R` - Combines all the final dominant data of the given lineage. 
- `./scrape_final_dominant_data.sh` - Calls `./combine_final_dominant_data.R` from the initial 200 replicates or from specific replays (configurable inside)
- `./scrape_final_max_fit_orgs.sh` - Aggregates the highest fitness org at the end of evolution for the initial 200 replicates. 
### Mutants
- `./combine_learning_muts.R` - Combines multiple learning mutation summary files into one. 
- `./combine_mutation_analysis.R` - Combines multiple mutation classification files into one, which is simply how many mutants fall into each category. 
- `./combine_one_step_mutation_analysis.R` - Combine multiple one-step mutation classification files into one. 
- `./scrape_learning_muts.sh`- Manually combines multiple learning mutation summary files into one. 
