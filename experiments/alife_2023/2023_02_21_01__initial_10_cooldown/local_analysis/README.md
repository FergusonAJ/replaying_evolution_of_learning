## Directory

### Files that _should_ be edited
- `./process_all.sh` - Does all the heavy lifting. Can be used to generate or compare data with a flag inside. 

### Helper scripts
- `./draw_trace.sh` - Visualizes an organism's trace
- `./get_genome.R` - Fetches the genome at a certain depth of a lineage. 
- `./process_one.sh` - Runs all data for a single depth in a lineage. 
- `./random_seed.txt` - The random seed to use. Changed by `./process_all.sh`
- `./run_job.sb` - The actual analysis executable. 
- `./scrape_trace.sh` - Converts a full organism output file into a usable execution trace. 

### Required files
- `./shared_files/` - Contains all the files needed to run the analyses.

Note: `shared_files.tar.gz` and `data.tar.gz` should be decompressed. Simply run `tar -xzf shared_files.tar.gz` and `tar -xzf data.tar.gz`. 
