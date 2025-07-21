#!/bin/bash
#PBS -l ncpus=48,mem=190GB,walltime=12:00:00,storage=gdata/if89+gdata/te53+gdata/xl04,jobfs=400GB
#PBS -q normal
#PBS -P te53
#PBS -N srf
#PBS -j oe
#PBS -o /g/data/te53/t2t2024/logs/

set -ex

#example usage: qsub -v inputfasta=asm.fasta,OUTPUTDIR=/path/to/output/directory/,window2refchains=window2ref.chains runtrf.sh
#todo: may not be issues in the longer run once workflow is settled
#1. output is only taking care of .fasta.gz extension, need to work with variety of extensions
#2. assumes bgzip compressed file for samtools faidx

module load KMC/3.2.4 k8/1.0 minimap2/2.28 parallel/20191022 samtools/1.19.2 pythonlib/3.9.2 TRF-mod/4.10.0 utils/0.0

##need to put this in if89 or other central location later
export SRFBIN=/g/data/te53/hrp561/tmp/srf/
#export MASKFA=/g/data/te53/hrp561/refgen/python/maskFasta.py

mkdir -p ${OUTPUTDIR}

# Check if the process has already been completed
if [ -e ${OUTPUTDIR}/${sampleid}.srftrf.done ]
then
    echo "Skipping ${sampleid} as analysis is already done"
    exit 0
fi


# Run the srf analysis
cd ${PBS_JOBFS}
## run srf on each contig. This will avoid collapsing alpha-HORs that may be "identical" between contigs/chromosomes
## a pooled version for all contigs can also be done if needed to identify alpha-HORs that are shared between individuals and contigs/chromosomes. this is a later problem
## create index if required
if [ ! -e ${inputfasta}.fai ]
then
    samtools faidx ${inputfasta}
fi

for contig in $(cut -f1 ${inputfasta}.fai)
do
    ## this is a bit of a hack to avoid re-running the analysis if it is already done. has not effect when run on $PBS_JOBFS.
    if [ -s ${sampleid}.${contig}.srf.done ]
    then
        echo "Skipping ${sampleid}.${contig} as analysis is already done"
        continue
    fi
    
    samtools faidx ${inputfasta} ${contig} >${sampleid}.${contig}.fa
    ##-ci20 was used by the paper for contigs, -k101 is different to the paper
    kmc -fm -k${klen} -t${PBS_NCPUS} -ci20 -cs100000 ${sampleid}.${contig}.fa ${sampleid}.${contig}.kmc ./ &>${sampleid}.${contig}.kmc.log
    kmc_dump ${sampleid}.${contig}.kmc ${sampleid}.${contig}.counts.txt &>>${sampleid}.${contig}.kmc.log
    
    if [ -s ${sampleid}.${contig}.counts.txt ]
    then
        ${SRFBIN}/srf -p ${sampleid}.${contig} ${sampleid}.${contig}.counts.txt >${sampleid}.${contig}.srf.fa
        minimap2 -t ${PBS_NCPUS} -c -N1000000 -f1000 -r100,100 <(${SRFBIN}/srfutils.js enlong ${sampleid}.${contig}.srf.fa) ${sampleid}.${contig}.fa >${sampleid}.${contig}.asm2srf.paf
        ${SRFBIN}/srfutils.js paf2bed ${sampleid}.${contig}.asm2srf.paf > ${sampleid}.${contig}.asm2srf.bed
        ${SRFBIN}/srfutils.js bed2abun ${sampleid}.${contig}.asm2srf.bed > ${sampleid}.${contig}.asm2srf.abun
        maskFasta.py --fasta_file ${sampleid}.${contig}.fa --bed_file ${sampleid}.${contig}.asm2srf.bed --output_file ${sampleid}.${contig}.masked.fa
    else
        continue
    fi
    touch ${sampleid}.${contig}.srf.done
done


# run TRF function
# run_trf_mod() {
#     local input_file="$1"
#     local output_file="${input_file%.fa}.trf"
#     trf-mod "$input_file" > "$output_file"
# }
# export -f run_trf_mod
# parallel --joblog "${sampleid}.trf.log" -j "${PBS_NCPUS}" --resume run_trf_mod ::: "${sampleid}".*.masked.fa

# cat ${sampleid}.*.trf | perl -lne '@a = split ("\t", $_); $id++; print join("\t", @a)."\ttrf$id"' |\
# tee >(cut -f1-3,11 >${OUTPUTDIR}/${sampleid}.trf.bed) >${OUTPUTDIR}/${sampleid}.trf.out

cat ${sampleid}.*.asm2srf.abun >${OUTPUTDIR}/${sampleid}.asm2srf.abun
cat ${sampleid}.*.asm2srf.bed >${OUTPUTDIR}/${sampleid}.asm2srf.bed
cat ${sampleid}.*.asm2srf.paf >${OUTPUTDIR}/${sampleid}.asm2srf.paf
cat ${sampleid}.*.srf.fa >${OUTPUTDIR}/${sampleid}.srf.fa
cat ${sampleid}.*.kmc.log >${OUTPUTDIR}/${sampleid}.kmc.log

## following is optional since PBS_JOBFS will be cleaned up by PBS
## this is for insurance purposes where PBS_JOBFS is not used
for contig in $(cut -f1 ${inputfasta}.fai)
do
    rm -f ${sampleid}.${contig}.fa
    rm -f ${sampleid}.${contig}.kmc
    rm -f ${sampleid}.${contig}.counts.txt
    rm -f ${sampleid}.${contig}.srf.fa
    rm -f ${sampleid}.${contig}.asm2srf.paf
    rm -f ${sampleid}.${contig}.asm2srf.bed
    rm -f ${sampleid}.${contig}.asm2srf.abun
    rm -f ${sampleid}.${contig}.masked.fa
    rm -f ${sampleid}.${contig}.kmc.log
    rm -f ${sampleid}.${contig}.kmc.kmc_suf
    rm -f ${sampleid}.${contig}.kmc.kmc_pre
#    rm -f ${sampleid}.${contig}.masked.trf
done

# Create the done file
touch ${OUTPUTDIR}/${sampleid}.srftrf.done