process asmtable {

    publishDir "${params.outdir}/${sample}/analysis/asmqc/${assembler}/asmtable/${asmtype}", mode: 'copy', pattern : "*asmtable.csv"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*asmtable.csv")

    script:
    
    """
    
    python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/asmtable.py -fasta ${asmfasta} -outdir \${PWD} -sample "${sample}.${assembler}.${asmtype}"
    
    """

    stub:

    """
    touch "${sample}.${assembler}.${asmtype}.test.asmtable.csv"
    """
}

