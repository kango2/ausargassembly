process gaps {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*gaps.bed")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.gaps.bed"
    """
}

