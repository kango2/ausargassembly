#!/bin/bash

fast5out=/g/data/xl04/ka6418/ausargassembly/testdata/ont/fast5
fast5tar=/g/data/xl04/ka6418/ausargassembly/testdata/ont/tar
mkdir -p "$fast5out"

passtar=/g/data/xl04/bpadata/Pogona_vitticeps/basecallingv2/bpa_d155e1b1_20240717T0657/350783_PAF10280_AusARG_RamaciottiGarvan_ONTPromethION_fast5_pass.tar
failtar=/g/data/xl04/bpadata/Pogona_vitticeps/basecallingv2/bpa_d155e1b1_20240717T0657/350783_PAF10280_AusARG_RamaciottiGarvan_ONTPromethION_fast5_fail.tar

passtesttar="${fast5tar}/$(basename "${passtar%.tar}_test.tar")"
failtesttar="${fast5tar}/$(basename "${failtar%.tar}_test.tar")"

# Function: extract last 10 files, rename with _test, re-tar
extract_rename_retar() {
    local input_tar="$1"
    local output_tar="$2"
    local temp_dir="$fast5out"  # Use fast5out as temp dir (as you said)

    mkdir -p "$temp_dir"

    echo "🔍 Processing $input_tar → $output_tar"

    # Get last 10 file paths from tar (with full internal path)
    filelist=$(tar -tvf "$input_tar" | awk '{print $NF}' | sort | tail -n 10)

    # Extract and flatten directory structure using --strip-components
    tar -xvf "$input_tar" -C "$temp_dir" --strip-components=1 $filelist

    # Create a new tar archive with renamed files
    tar -cvf "$output_tar" --exclude="$(basename "$output_tar")" -C "$temp_dir" .

    # Cleanup
    rm -rf "$temp_dir"/*_test.fast5.gz
    echo "✅ Created: $output_tar"
}

extract_rename_retar "$passtar" "$passtesttar"
extract_rename_retar "$failtar" "$failtesttar"
