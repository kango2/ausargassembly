
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

#!/bin/bash
set -euo pipefail


# === INPUT VARIABLES ===

assembly="/g/data/xl04/genomeprojects/Pogona_vitticeps/fasta/POGVIT.v2.1.fasta"
illuminabam="/g/data/xl04/genomeprojects/Pogona_vitticeps/analysis/depth/rearranged/POGVIT.v2.1.merged.illum.bam"
pbbam="/g/data/xl04/genomeprojects/Pogona_vitticeps/analysis/depth/rearranged/POGVIT.v2.1.merged.pb.bam"
ontbam="/g/data/xl04/genomeprojects/Pogona_vitticeps/analysis/depth/rearranged/POGVIT.v2.1.merged.ont.bam"

illuminafastq="/g/data/xl04/bpadata/Pogona_vitticeps/raw/illumina/dnaseq/Pogona_combined_ILM.1.fastq.gz;/g/data/xl04/bpadata/Pogona_vitticeps/raw/illumina/dnaseq/Pogona_combined_ILM.2.fastq.gz"
ontfastq="/g/data/xl04/bpadata/Pogona_vitticeps/raw/ONT/fastx/PLPN155056_FLO-PRO002_PAF10280_sqk-lsk109_80_pagona.pass.fastq.gz:/g/data/xl04/bpadata/Pogona_vitticeps/raw/ONT/fastx/PLPN156056_FLO-PRO002_PAF14969_sqk-lsk109_4_pagona.pass.fastq.gz:/g/data/xl04/bpadata/Pogona_vitticeps/raw/ONT/fastx/PLPN162061_FLO-PRO002_PAF09661_sqk-lsk109_pogona.pass.fastq.gz:/g/data/xl04/bpadata/Pogona_vitticeps/raw/ONT/fastx/PLPN165068-2_FLO-PRO002_PAF09309_sqk-lsk109_SRE_pogona.pass.fastq.gz:/g/data/xl04/bpadata/Pogona_vitticeps/raw/ONT/fastx/PZPN233125_FLO-PRO002_PAF21165_sqk-rad004_Pogona_UL.pass.fastq.gz:/g/data/xl04/bpadata/Pogona_vitticeps/raw/ONT/fastx/PZPN235126-2_FLO-PRO002_PAF32809_sqk-rad004_Pogona_repeat.pass.fastq.gz"
pbfastq="/g/data/xl04/bpadata/Pogona_vitticeps/raw/pacbio/pogona.hifi_reads_trimmed.fastq.gz"

scaffold="scaffold_10"

# === LOAD MODULES ===
module load samtools seqtk

PBS_JOBFS="/g/data/xl04/ka6418/testing/tempjobfs"

# === EXTRACT READ IDS ===
echo "[INFO] Extracting read IDs from scaffold: $scaffold"
samtools view "$illuminabam" "$scaffold" | cut -f1 | sort -u > "$PBS_JOBFS/illumina.reads.txt"
samtools view "$ontbam" "$scaffold" | cut -f1 | sort -u > "$PBS_JOBFS/ont.reads.txt"
samtools view "$pbbam" "$scaffold" | cut -f1 | sort -u > "$PBS_JOBFS/pb.reads.txt"

# === SUBSET ILLUMINA (PAIRED-END) ===
echo "[INFO] Subsetting Illumina paired-end FASTQs"
IFS=';' read -ra illumina_fqs <<< "$illuminafastq"
R1="${illumina_fqs[0]}"
R2="${illumina_fqs[1]}"
seqtk subseq "$R1" "$PBS_JOBFS/illumina.reads.txt" > "$PBS_JOBFS/illumina.R1.subset.fastq"
seqtk subseq "$R2" "$PBS_JOBFS/illumina.reads.txt" > "$PBS_JOBFS/illumina.R2.subset.fastq"
pigz -f "$PBS_JOBFS/illumina.R1.subset.fastq"
pigz -f "$PBS_JOBFS/illumina.R2.subset.fastq"

# === SUBSET ONT (SINGLE-END MULTIPLE FILES) ===
echo "[INFO] Subsetting ONT FASTQs"
IFS=':' read -ra ont_fqs <<< "$ontfastq"
> "$PBS_JOBFS/ont.subset.fastq"
for fq in "${ont_fqs[@]}"; do
    echo "  [ONT] Processing $fq"
    seqtk subseq "$fq" "$PBS_JOBFS/ont.reads.txt" >> "$PBS_JOBFS/ont.subset.fastq"
done
pigz -f "$PBS_JOBFS/ont.subset.fastq"

# === SUBSET PACBIO (SINGLE-END SINGLE FILE) ===
echo "[INFO] Subsetting PacBio FASTQ"
seqtk subseq "$pbfastq" "$PBS_JOBFS/pb.reads.txt" > "$PBS_JOBFS/pb.subset.fastq"
pigz -f "$PBS_JOBFS/pb.subset.fastq"

# === OUTPUT DONE ===
echo "[INFO] Subsetting complete."
echo "[INFO] Output files:"
ls -lh "$PBS_JOBFS"/*subset.fastq.gz



#AFTER DONE, we intentionally split them in parts to emulate multiple files for workflow
