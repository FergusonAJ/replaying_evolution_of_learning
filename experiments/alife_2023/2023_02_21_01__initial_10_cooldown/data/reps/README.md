Here we'll summarize the files in each folder. Each folder should have the same structure, so this prevents having many duplicate files. 

In this folder, each subdirectory represents one of the initial 200 replicates. Specifically, these were the four lineages we analyzed in the paper. 

Lineage A -> Seed 86
Lineage B -> Seed 4
Lineage C -> Seed 15
Lineage D -> Seed 6

Any other seeds were not included in the paper because of time constraints on data collection.

## Per-seed directory structure
- `./${SEED}/dominant_lineage.csv` - The raw lineage data from the original evolution run. Contains info like the genome, origin time, etc. of each step in the lineage. 
- `./${SEED}/dominant_lineage_summary.csv` - A summary of how each step in the lineage performed, looking at things like accuracy and merit. Includes the category each step in the lineage was classified to. 
- `./${SEED}/seq_data.csv` - The genome of each step in the lineages, aligned so that insertions/deletions do not break columns. $ represents an "filler" cell used to achieve that alignment. 
- `./${SEED}/replays/missing_seeds.csv` - As mentioned in the paper, some replay replicates went extinct immediately. Here we give details on those seeds. 
- `./${SEED}/replays/processed_data/processed_replay_summary.csv` - A summary of all 50 replicates launched from every replay depth. 
- `./${SEED}/replays/processed_data/processed_replay_classification.csv` - A summary of the categories at each replay depth (e.g., the number of learning replicates at each depth). 
- `./${SEED}/replays/processed_data/processed_learning_summary.csv` - A of subset of the classification data looking only at learning, with additional info on what behavior was performed by the lineage at each step. 
