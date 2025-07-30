import csv

input_file = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fixed-tiliqua-fastq-29july-tiliqua.csv.tmp"
output_file = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fixed-tiliqua-fastq-29july-tiliqua.csv"

with open(input_file, newline='') as infile, open(output_file, "w", newline='') as outfile:
    reader = csv.DictReader(infile)
    fieldnames = reader.fieldnames
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    writer.writeheader()

    for row in reader:
        if row['tech'].lower() == 'illumina':
            organism = row['sample']  # dynamically pulled from each row
            runid = row['runid']
            base = f"/g/data/xl04/bpadownload2025/{organism}/illumina/{runid}/fastx/{organism}.{runid}"
            row['file'] = f"{base}.R1.trimmed.fastq.gz;{base}.R2.trimmed.fastq.gz"
        writer.writerow(row)