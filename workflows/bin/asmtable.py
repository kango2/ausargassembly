import argparse
from Bio import SeqIO
import re
import os
import csv

def compute_stats(fasta_path):
    lengths = []
    total_gc = 0
    total_length = 0
    num_contigs = 0
    contigs_over_1mb = 0
    contigs_over_50kb = 0
    max_contig = 0
    num_gaps = 0

    for record in SeqIO.parse(fasta_path, "fasta"):
        seq = str(record.seq).upper()
        seqlen = len(seq)
        if seqlen == 0:
            continue
        num_contigs += 1
        lengths.append(seqlen)
        total_length += seqlen
        total_gc += seq.count('G') + seq.count('C')
        num_gaps += len(re.findall(r'N+', seq))
        if seqlen >= 1_000_000:
            contigs_over_1mb += 1
        if seqlen >= 50_000:
            contigs_over_50kb += 1
        if seqlen > max_contig:
            max_contig = seqlen

    lengths.sort(reverse=True)

    def nx(n):
        threshold = total_length * (n / 100)
        running = 0
        for i, l in enumerate(lengths):
            running += l
            if running >= threshold:
                return l, i + 1
        return 0, 0

    n50, l50 = nx(50)
    n90, l90 = nx(90)

    gc_percent = round((total_gc / total_length) * 100, 2) if total_length else 0

    return {
        "number_of_contigs": num_contigs,
        "total_len": total_length,
        "contigs_over_1mb": contigs_over_1mb,
        "contigs_over_50kb": contigs_over_50kb,
        "largest_contig_len": max_contig,
        "n50": n50,
        "l50": l50,
        "n90": n90,
        "l90": l90,
        "gc": gc_percent,
        "num_gaps": num_gaps
    }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compute basic assembly QC stats and write to CSV.")
    parser.add_argument("-fasta", required=True, help="Input FASTA file")
    parser.add_argument("-sample", required=True, help="Sample name")
    parser.add_argument("-outdir", required=True, help="Output directory")
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    stats = compute_stats(args.fasta)

    csv_file = os.path.join(args.outdir, f"{args.sample}_asmtable.csv")
    with open(csv_file, 'w', newline='') as csvfile:
        fieldnames = ['sample'] + list(stats.keys())
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        row = {'sample': args.sample}
        row.update(stats)
        writer.writerow(row)

