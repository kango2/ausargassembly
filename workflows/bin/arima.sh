#!/bin/bash
#PBS -N arima
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=2:00:00
#PBS -l mem=192GB
#PBS -l ncpus=48
#PBS -l storage=gdata/xl04+gdata/if89
#PBS -l wd
#PBS -l jobfs=400GB
#PBS -j oe
#PBS -M kirat.alreja@anu.edu.au

set -ex

module load samtools/1.21 parallel/20191022 bwa/0.7.17
export JAVA_HOME=/apps/java/jdk-17.0.2/bin/java
picardjar=/g/data/if89/apps/picard/2.27.4/picard.jar

#qsub -v R1,R2,fasta,sample,outputdir


WORK_DIR=${PBS_JOBFS}
label=${sample}
REF=${fasta}

mkdir -p $WORK_DIR
cd $WORK_DIR

mkdir -p fastq
ln -sf ${R1} fastq/${label}_R1.fastq.gz
ln -sf ${R2} fastq/${label}_R2.fastq.gz

IN_DIR=fastq
SRA=$label
LABEL=$label
FAIDX="${fasta}.fai"
RAW_DIR="$WORK_DIR/raw"
FILT_DIR="$WORK_DIR/filt"
TMP_DIR="$WORK_DIR/temp"
PAIR_DIR="$WORK_DIR/pair"
REP_DIR="$WORK_DIR/dedup"
REP_LABEL="${label}_rep1"
FILTER="/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/filter_five_end.pl"
COMBINER="/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/two_read_bam_combiner.pl"
STATS="/g/data/xl04/ka6418/github/ausargassembly/workflows/bin/get_stats.pl"

MAPQ_FILTER=10
CPU=${PBS_NCPUS}

echo "### Step 0: Check output directories' existence & create them as needed"
[ -d $RAW_DIR ] || mkdir -p $RAW_DIR
[ -d $FILT_DIR ] || mkdir -p $FILT_DIR
[ -d $TMP_DIR ] || mkdir -p $TMP_DIR
[ -d $PAIR_DIR ] || mkdir -p $PAIR_DIR
[ -d $REP_DIR ] || mkdir -p $REP_DIR
[ -d $MERGE_DIR ] || mkdir -p $MERGE_DIR

if [[ -f "$REF.amb" && -f "$REF.ann" && -f "$REF.bwt" && -f "$REF.pac" && -f "$REF.sa" ]]; then
   echo "BWA index exists"
else
    echo "BWA index does not exist, creating index..."
    bwa index -a bwtsw $REF
fi

if [[ -f "$REF.fai" ]]; then
    echo "Samtools index exists"
else
    echo "Samtools index does not exist, creating index..."
    samtools faidx $REF
fi

HALF_CPU=$((PBS_NCPUS / 2))

#Step 1: FASTQ to BAM
echo -e "${SRA}_R1.fastq.gz\n${SRA}_R2.fastq.gz" | parallel -j 2 --eta \
"bwa mem -t $HALF_CPU $REF $IN_DIR/{} | samtools view -@ $HALF_CPU -Sb - > $RAW_DIR/{/.}.bam"

# Step 2: Filter 5' end
echo -e "${SRA}_R1.fastq.bam\n${SRA}_R2.fastq.bam" | parallel -j 2 --eta \
"samtools view -h $RAW_DIR/{} | perl $FILTER | samtools view -Sb - > $FILT_DIR/{}"

#echo "### Step 3A: Pair reads & mapping quality filter"
perl $COMBINER $FILT_DIR/${SRA}_R1.fastq.bam $FILT_DIR/${SRA}_R2.fastq.bam samtools $MAPQ_FILTER | samtools view -bS -t $FAIDX - | samtools sort -@ $CPU -o $TMP_DIR/$SRA.bam -

#echo "### Step 3.B: Add read group"
java -jar ${picardjar} AddOrReplaceReadGroups INPUT=$TMP_DIR/$SRA.bam OUTPUT=$PAIR_DIR/$SRA.bam ID=$SRA LB=$SRA SM=$LABEL PL=ILLUMINA PU=none

#echo "### Step 4: Mark duplicates"
java -jar ${picardjar} MarkDuplicates INPUT=$PAIR_DIR/$SRA.bam OUTPUT=$REP_DIR/$REP_LABEL.bam METRICS_FILE=$REP_DIR/metrics.$REP_LABEL.txt TMP_DIR=$TMP_DIR ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE

samtools index $REP_DIR/$REP_LABEL.bam

cd dedup 
mv ${label}_rep1.bam ${label}_arimahic.bam 
mv ${label}_rep1.bam.bai ${label}_arimahic.bam.bai
mv ${label}_arimahic.bam ${outputdir}
mv ${label}_arimahic.bam.bai ${outputdir}
