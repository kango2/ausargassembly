process gc {

    publishDir "${params.outdir}/gaps", mode: 'copy', pattern : "*GC.bed"

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*GC.bed")

    script:
    
    """

    input="${asmfasta}"

    output="\${PWD}"

    sample="${sample}.${asmtype}.${assembler}"

    export input output sample

    bash /g/data/xl04/ka6418/github/ausargassembly/workflows/bin/calculateGC.sh
    
    """

    stub:

    """
    touch "${sample}.${assembler}.${asmtype}.test_GC.bed"
    """
}

