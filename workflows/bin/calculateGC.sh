#!/bin/bash
#PBS -N gc_calculation
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=05:00:00
#PBS -l mem=32GB
#PBS -l ncpus=48
#PBS -l storage=gdata/xl04+gdata/if89
#PBS -l wd
#PBS -l jobfs=100GB
#PBS -M kirat.alreja@anu.edu.au

#qsub -v input,output,sample 

# Load modules
module load parallel/20191022 biopython/1.79 kentutils/0.0

# Input and output paths
inputfile="$input"
outputdir="$output"

# Split fasta into 10kb chunks
faSplit sequence "$inputfile" 10000 ${PBS_JOBFS}/chunk

cd ${PBS_JOBFS}

# List chunk files and run GC calc in parallel
ls chunk* | parallel -j ${PBS_NCPUS} python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/calculateGC.py {}

# Merge all BED outputs
awk 'FNR==1 || NR!=1' *.bed > "${outputdir}/${sample}_GC.bed"
