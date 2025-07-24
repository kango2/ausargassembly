#!/bin/bash
#PBS -N makingtestdata
#PBS -P xl04
#PBS -q normal
#PBS -l storage=gdata/xl04+gdata/if89+gdata/te53
#PBS -l walltime=3:00:00
#PBS -l mem=192GB
#PBS -l ncpus=48
#PBS -l jobfs=400GB
#PBS -l wd
#PBS -j oe

#!/bin/bash
set -euo pipefail

# === INPUT VARIABLES ===

assembly="/g/data/xl04/genomeprojects/Pogona_vitticeps/fasta/hifiasm-corrected/POGVITdef.p.corrected.fasta"
illuminabam="/g/data/xl04/genomeprojects/Pogona_vitticeps/analysis/scaffolding/bam/POGVITdef.p.corrected_ArimaHiC.bam"
illuminafastq="/g/data/xl04/bpadata/Pogona_vitticeps/raw/illumina/hic/pogona_hic_R1.fastq.gz;/g/data/xl04/bpadata/Pogona_vitticeps/raw/illumina/hic/pogona_hic_R2.fastq.gz"
scaffold="ptg000001l"

# === LOAD MODULES ===
module load samtools seqtk

PBS_JOBFS="/g/data/xl04/ka6418/ausargassembly/testdata/hic/tmp"
#samtools index "$illuminabam"
# === EXTRACT READ IDS ===
echo "[INFO] Extracting read IDs from scaffold: $scaffold"
#samtools view "$illuminabam" "$scaffold" | cut -f1 | sort -u > "$PBS_JOBFS/hic.reads.txt"

# === SUBSET ILLUMINA (PAIRED-END) ===
echo "[INFO] Subsetting Illumina paired-end FASTQs"
IFS=';' read -ra illumina_fqs <<< "$illuminafastq"
R1="${illumina_fqs[0]}"
R2="${illumina_fqs[1]}"
seqtk subseq "$R1" "$PBS_JOBFS/hic.reads.txt" > "$PBS_JOBFS/hic.R1.subset.fastq"
seqtk subseq "$R2" "$PBS_JOBFS/hic.reads.txt" > "$PBS_JOBFS/hic.R2.subset.fastq"
pigz -f "$PBS_JOBFS/hic.R1.subset.fastq"
pigz -f "$PBS_JOBFS/hic.R2.subset.fastq"

mv "$PBS_JOBFS/hic.R1.subset.fastq" ${outdir}/hic.R1.subset.fastq.gz
mv "$PBS_JOBFS/hic.R2.subset.fastq" ${outdir}/hic.R2.subset.fastq.gz


