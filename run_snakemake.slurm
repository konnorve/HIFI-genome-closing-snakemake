#!/usr/bin/env bash
#SBATCH --job-name=PBsmk
#SBATCH --time 20-0                         # wall clock limit
#SBATCH -p sched_mit_chisholm               # partition selection
#SBATCH -n 1                                # tasks (essentially threads)
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err

source activate snakemake

snakemake -s workflow/Snakefile --unlock --configfile "config.yaml"

# run job:
snakemake \
    --configfile "config.yaml" \
    -s workflow/Snakefile \
    --use-conda \
    --slurm \
    --rerun-incomplete \
    --jobs 10
    # --keep-going