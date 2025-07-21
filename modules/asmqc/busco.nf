process busco {

    publishDir "${params.outdir}/alignreads", mode: 'copy', pattern : "*${sample}.${asmtype}.${assembler}*"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*full_table.tsv"), path ("*short_summary.json"), path ("*missing_busco_list.tsv")

    script:
    
    """

    fasta=${asmfasta}
    export fasta
    
    outdir="\${PWD}"
    export outdir

    prefix="${sample}.${asmtype}.${assembler}"
    export prefix

    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/busco.sh

    find . -name "missing_busco_list.tsv" -exec mv {} \${PWD}/"\${prefix}.missing_busco_list.tsv" \\;
    find . -name "short_summary.json" -exec mv {} \${PWD}/"\${prefix}.short_summary.json" \\;
    find . -name "full_table.tsv" -exec mv {} \${PWD}/"\${prefix}.full_table.tsv" \\;

    """

    stub:

    """
    
    touch "${sample}_${assembler}_${asmtype}.full_table.tsv"
    touch "${sample}_${assembler}_${asmtype}.short_summary.json"
    touch "${sample}_${assembler}_${asmtype}.missing_busco_list.tsv"

    """
}
