#!/bin/bash
#PBS -N yahstojuicer
#PBS -P te53
#PBS -q normal
#PBS -l walltime=3:30:00
#PBS -l mem=64GB
#PBS -l ncpus=16
#PBS -l storage=gdata/xl04+gdata/if89
#PBS -l wd

set -ex
module load seqkit/2.9.0 samtools

juicer=/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/yahstojuicer/juicer
juicer_tools=/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/yahstojuicer/juicer_tools.1.9.9_jcuda.0.8.jar

cd ${PBS_JOBFS}

seqkit sort -lr ${fasta} > ${sample}.tmp.fasta
samtools faidx ${sample}.tmp.fasta
#qsub -v bin,agp,fasta,output,sample

$juicer pre -o ${sample} -a ${bin} ${agp} "${sample}.tmp.fasta.fai" > ${sample}.log 2>&1

java -jar -Xmx32G $juicer_tools pre ${sample}.txt ${sample}.hic.part <(cat ${sample}.log  | grep PRE_C_SIZE | awk '{print $2" "$3}')

mv ${sample}.hic.part ${output}/${sample}.hic
mv ${sample}.assembly ${output}/${sample}.assembly 