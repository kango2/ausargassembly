#!/bin/bash
#PBS -N makingtestdata
#PBS -P xl04
#PBS -q normal
#PBS -l storage=gdata/xl04+gdata/if89+gdata/te53
#PBS -l walltime=4:00:00
#PBS -l mem=192GB
#PBS -l ncpus=48
#PBS -l wd
#PBS -j oe

PB_BAM=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/pacbio/subreads/350730_AusARG_AGRF_PacBio_DA060219.subreads.bam
PB_FASTQ=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/pacbio/fastx/DeepConsensus/DA060219_deepconsensus.fastq.gz
ONT_FASTQ=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/ont/fastx/SUP/PAF30832_SUP.fastq.gz
ONT_BLOW5=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/ont/blow5/PAF30832.blow5
illumina_r1=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/illumina/dnaseq/350747_AusARG_UNSW_HTYH7DRXX_GTATTCCACC-TTGTCTACAT_S2_L001_R1_001.fastq.gz
illumina_r2=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/illumina/dnaseq/350747_AusARG_UNSW_HTYH7DRXX_GTATTCCACC-TTGTCTACAT_S2_L001_R2_001.fastq.gz
hic_r1=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/illumina/hic/350769_AusARG_BRF_HCN7WDRXY_S5_L001_R1_001.fastq.gz
hic_r2=/g/data/xl04/bpadata/Bassiana_duperreyi/raw/illumina/hic/350769_AusARG_BRF_HCN7WDRXY_S5_L001_R2_001.fastq.gz
reads=1000
fraction=0.0001
threads=48
outdir=/g/data/xl04/ka6418/ausargassembly/testdata/rawdatamodule

/g/data/xl04/ka6418/github/ausargassembly/testdata/rawdataqc.sh \
 --pb_bam "$PB_BAM" \
    --pb_fastq "$PB_FASTQ" \
    --ont_fastq "$ONT_FASTQ" \
    --ont_blow5 "$ONT_BLOW5" \
    --illumina_r1 "$illumina_r1" \
    --illumina_r2 "$illumina_r2" \
    --hic_r1 "$hic_r1" \
    --hic_r2 "$hic_r2" \
    --reads "$reads" \
    --fraction "$fraction" \
    --threads "$threads" \
    --outdir "$outdir"