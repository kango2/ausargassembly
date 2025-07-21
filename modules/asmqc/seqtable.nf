process seqtable {

    publishDir "${params.outdir}/gaps", mode: 'copy', pattern : "*seqtable.csv"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*seqtable.csv")

    script:
    
    """

    python3 /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/seqtable.py -fasta ${asmfasta} -outputdir \${PWD} -sample "${sample}.${assembler}.${asmtype}" -p ${task.cpus}
    
    """

    stub:

    """
    touch "${sample}.${assembler}.${asmtype}.test.seqtable.csv"
    """
}

