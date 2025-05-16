#!/bin/bash

set -euo pipefail

module load samtools htslib seqtk slow5tools

# Defaults
READS=10000
FRACTION="0.001"
THREADS=4
OUTDIR="testdata"

usage() {
  echo "Usage: $0 [--pb_bam FILE] [--pb_fastq FILE] [--ont_fastq FILE] [--ont_blow5 FILE] [--illumina_r1 FILE] [--illumina_r2 FILE] [--hic_r1 FILE] [--hic_r2 FILE] [--reads N] [--fraction F] [--threads N] [--outdir DIR]"
  exit 1
}

# Parse args
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --pb_bam) PB_BAM="$2"; shift ;;
    --pb_fastq) PB_FASTQ="$2"; shift ;;
    --ont_fastq) ONT_FASTQ="$2"; shift ;;
    --ont_blow5) ONT_BLOW5="$2"; shift ;;
    --illumina_r1) ILLUMINA_R1="$2"; shift ;;
    --illumina_r2) ILLUMINA_R2="$2"; shift ;;
    --hic_r1) HIC_R1="$2"; shift ;;
    --hic_r2) HIC_R2="$2"; shift ;;
    --reads) READS="$2"; shift ;;
    --fraction) FRACTION="$2"; shift ;;
    --threads) THREADS="$2"; shift ;;
    --outdir) OUTDIR="$2"; shift ;;
    *) echo "Unknown param: $1"; usage ;;
  esac
  shift
done

mkdir -p "$OUTDIR"
echo "🛠️  Generating test data (reads=${READS}, fraction=${FRACTION}, threads=${THREADS}) in '$OUTDIR'..."

# PacBio BAM
if [[ -n "${PB_BAM:-}" ]]; then
  echo "📦 Subsetting PacBio BAM with -s $FRACTION..."
  samtools view -@ "$THREADS" -s "$FRACTION" -b "$PB_BAM" > "$OUTDIR/pacbio.sub.bam"
fi

# PacBio FASTQ
if [[ -n "${PB_FASTQ:-}" ]]; then
  echo "📦 Subsetting PacBio FASTQ and compressing..."
  seqtk sample -s100 "$PB_FASTQ" "$READS" | bgzip -@ "$THREADS" -c > "$OUTDIR/pacbio.sub.fastq.gz"
fi

# ONT FASTQ
if [[ -n "${ONT_FASTQ:-}" ]]; then
  echo "📦 Subsetting ONT FASTQ and compressing..."
  seqtk sample -s100 "$ONT_FASTQ" "$READS" | bgzip -@ "$THREADS" -c > "$OUTDIR/ont.sub.fastq.gz"
fi

# ONT BLOW5
if [[ -n "${ONT_BLOW5:-}" ]]; then
  echo "📦 Subsetting ONT BLOW5..."
  slow5tools view -t "$THREADS" -c -r "$READS" "$ONT_BLOW5" -o "$OUTDIR/ont.sub.blow5"
fi

# Illumina DNA-Seq FASTQ (paired-end)
if [[ -n "${ILLUMINA_R1:-}" && -n "${ILLUMINA_R2:-}" ]]; then
  echo "📦 Subsetting Illumina DNA-Seq R1/R2 and compressing..."
  seqtk sample -s100 "$ILLUMINA_R1" "$READS" | bgzip -@ "$THREADS" -c > "$OUTDIR/illumina.sub.R1.fastq.gz"
  seqtk sample -s100 "$ILLUMINA_R2" "$READS" | bgzip -@ "$THREADS" -c > "$OUTDIR/illumina.sub.R2.fastq.gz"
elif [[ -n "${ILLUMINA_R1:-}" || -n "${ILLUMINA_R2:-}" ]]; then
  echo "❌ Both --illumina_r1 and --illumina_r2 must be provided for DNA-Seq paired-end reads." >&2
  exit 1
fi

# Illumina Hi-C FASTQ (paired-end)
if [[ -n "${HIC_R1:-}" && -n "${HIC_R2:-}" ]]; then
  echo "📦 Subsetting Illumina Hi-C R1/R2 and compressing..."
  seqtk sample -s100 "$HIC_R1" "$READS" | bgzip -@ "$THREADS" -c > "$OUTDIR/hic.sub.R1.fastq.gz"
  seqtk sample -s100 "$HIC_R2" "$READS" | bgzip -@ "$THREADS" -c > "$OUTDIR/hic.sub.R2.fastq.gz"
elif [[ -n "${HIC_R1:-}" || -n "${HIC_R2:-}" ]]; then
  echo "❌ Both --hic_r1 and --hic_r2 must be provided for Hi-C paired-end reads." >&2
  exit 1
fi

echo "✅ All test data saved in '$OUTDIR/'"
ls -lh "$OUTDIR"
