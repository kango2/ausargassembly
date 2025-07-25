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

set -ex
module load seqkit bwa python3 parallel singularity

juicerimg=/g/data/if89/singularityimg/juicer.sif
JUICER_DIR=/g/data/xl04/ka6418/ausargassembly/testdata/hic/output/juicer
path_3d=/g/data/xl04/ka6418/ausargassembly/testdata/hic/output/3d-dna
path_greenhill=/g/data/xl04/ka6418/ausargassembly/testdata/hic/output/GreenHill
PBS_JOBFS=/g/data/xl04/ka6418/ausargassembly/testdata/hic/tmpdir
REF=/g/data/xl04/ka6418/ausargassembly/testdata/hic/POGVITdef.p.ptg000023l.fasta
R1=/g/data/xl04/ka6418/ausargassembly/testdata/hic/POGVITdef.p.ptg000023l.hic.R1.subset.fastq.gz
R2=/g/data/xl04/ka6418/ausargassembly/testdata/hic/POGVITdef.p.ptg000023l.hic.R2.subset.fastq.gz
WORK_DIR=/g/data/xl04/ka6418/ausargassembly/testdata/hic/analysis
scriptsdir=/g/data/xl04/ka6418/ausargassembly/testdata/hic/output/juicer/CPU
label=POGVIT 

label=$(basename ${REF} .fasta)
WORK_DIR=${PBS_JOBFS}
mkdir -p ${WORK_DIR}/fastq
ln -s ${R1} ${WORK_DIR}/fastq/${label}_R1.fastq.gz
ln -s ${R2} ${WORK_DIR}/fastq/${label}_R2.fastq.gz
cd ${WORK_DIR}
seqkit sort -lr ${REF} > base.fa
bwa index base.fa > bwa_index.log 
seqkit fx2tab -nl base.fa > base.sizes
python $JUICER_DIR/misc/generate_site_positions.py Arima base ${WORK_DIR}/base.fa
singularity exec ${juicerimg} /g/data/xl04/ka6418/ausargassembly/testdata/hic/output/juicer/CPU/juicer.sh  -D /g/data/xl04/ka6418/ausargassembly/testdata/hic/output/juicer/CPU -d ${WORK_DIR} -y ${WORK_DIR}/base_Arima.txt -t ${PBS_NCPUS}  -g base -s Arima -z base.fa -p base.sizes >juicer.log.o 2>juicer.log.e
#awk -f $path_3d/utils/generate-assembly-file-from-fasta.awk base.fa >base.assembly 2>generate.log.e
#$path_3d/visualize/run-assembly-visualizer.sh base.assembly aligned/merged_nodups.txt >visualizer.log.o 2>visualizer.log.e
python $path_greenhill/utils/fasta_to_juicebox_assembly.py base.fa >base.ctg_info.assembly

mv ${WORK_DIR}/aligned/inter_30.hic ${outdir}/${label}.hic