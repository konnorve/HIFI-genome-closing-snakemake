#!/usr/bin/env bash
#SBATCH --job-name=PBsmk
#SBATCH --time 10-0                         # wall clock limit
#SBATCH --partition sched_mit_chisholm      # partition selection
#SBATCH -N 2                                # nodes
#SBATCH -n 40                               # tasks (essentially threads)
#SBATCH --mem 250G                          # memory
#SBATCH -o logs/runs/%j_slurm_output.txt
#SBATCH -e logs/runs/%j_slurm_error.txt

source activate snakemake

# lints and formats snakefile
snakemake --unlock
snakemake --lint

# run job:
snakemake --cores all --resources mem_mb=500000 --use-conda --conda-frontend conda --rerun-incomplete --keep-going
