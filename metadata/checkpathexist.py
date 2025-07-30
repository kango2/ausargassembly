import csv
import os

input_csv = "/g/data/xl04/ka6418/github/ausargassembly/metadata/assembly-fastq-29july-notiliqua-trimmedillumina.csv"

missing = []

with open(input_csv, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        if row["tech"].lower() == "illumina":
            paths = row["file"].split(";")
            for path in paths:
                path = path.strip()
                if not os.path.exists(path):
                    missing.append((row["sample"], row["runid"], path))

if missing:
    print("❌ Missing files:")
    for sample, runid, path in missing:
        print(f"Sample: {sample}, RunID: {runid}, Missing: {path}")
else:
    print("✅ All Illumina files exist.")
