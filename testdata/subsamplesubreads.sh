#!/bin/bash
#PBS -N subsample
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=5:00:00
#PBS -l mem=192GB
#PBS -l ncpus=48
#PBS -l storage=gdata/xl04+gdata/if89
#PBS -l wd
#PBS -M kirat.alreja@anu.edu.au


module load samtools
samtools view -s 0.01 -b \
  /g/data/xl04/bpadata/Bassiana_duperreyi/raw/pacbio/subreads/350730_AusARG_AGRF_PacBio_DA060219.subreads.bam \
  -o /g/data/xl04/ka6418/ausargassembly/testdata/subsamplesubreads/subreads_1pct.bam
