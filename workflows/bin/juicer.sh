#!/bin/bash
#PBS -N juicer
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=4:00:00
#PBS -l mem=192GB
#PBS -l ncpus=48
#PBS -l storage=gdata/xl04+gdata/if89
#PBS -l wd
#PBS -j oe
#PBS -M kirat.alreja@anu.edu.au

#qsub -v fasta, R1,R2,sample,outdir

set -ex
module load seqkit/2.9.0 bwa/0.7.17 python3/3.12.1 parallel/20191022 singularity

juicerimg=/g/data/if89/singularityimg/juicer.sif
juicerbase=/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/juicer
juicerscripts=/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/juicer/CPU

workdir=${PBS_JOBFS}

mkdir -p ${workdir}/fastq

ln -sf ${R1} ${workdir}/fastq/${sample}_R1.fastq.gz
ln -sf ${R2} ${workdir}/fastq/${sample}_R2.fastq.gz

cd ${workdir}
seqkit sort -lr ${fasta} > ${sample}.fa
bwa index ${sample}.fa > bwa_index.log 
seqkit fx2tab -nl ${sample}.fa > ${sample}.sizes
python $juicerbase/misc/generate_site_positions.py Arima ${sample} ${workdir}/${sample}.fa
singularity exec ${juicerimg} ${juicerscripts}/juicer.sh -D ${juicerscripts} -d ${workdir} -y ${workdir}/${sample}_Arima.txt -t ${PBS_NCPUS}  -g ${sample} -s Arima -z ${sample}.fa -p ${sample}.sizes >juicer.log.o 2>juicer.log.e
#awk -f $path_3d/utils/generate-assembly-file-from-fasta.awk base.fa >base.assembly 2>generate.log.e
#$path_3d/visualize/run-assembly-visualizer.sh base.assembly aligned/merged_nodups.txt >visualizer.log.o 2>visualizer.log.e
python /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/fasta_to_juicebox_assembly.py ${sample}.fa > ${sample}.ctg_info.assembly
mv ${workdir}/aligned/inter_30.hic ${outdir}/${sample}.hic
mv ${sample}.ctg_info.assembly ${outdir}/${sample}.assembly