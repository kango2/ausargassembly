import sys

def read_fasta(file_path):
    with open(file_path, 'r') as f:
        sequences = {}
        current_header = None
        
        for line in f:
            line = line.strip()
            if line.startswith('>'):
                current_header = line[1:]
                sequences[current_header] = []
            else:
                sequences[current_header].append(line)
                
        for key, value in sequences.items():
            sequences[key] = ''.join(value)
            
        return sequences

def gc_content(seq, window=10000):
    entries = []
    for i in range(0, len(seq) - window + 1, window):
        subseq = seq[i:i+window]
        gc_count = subseq.upper().count('G') + subseq.upper().count('C')
        entries.append((i, i+window, gc_count))
    return entries

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Please provide the path to the FASTA file as an argument.")
        sys.exit(1)

    fasta_path = sys.argv[1]
    bed_path = fasta_path.rsplit('.', 1)[0] + '.bed'

    sequences = read_fasta(fasta_path)

    with open(bed_path, 'w') as bedfile:
        for header, seq in sequences.items():
            gc_regions = gc_content(seq)
            for start, end, count in gc_regions:
                bedfile.write(f"{header}\t{start}\t{end}\t{count}\n")

    print(f"Wrote BED to: {bed_path}")
