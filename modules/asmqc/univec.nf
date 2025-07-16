process univec {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    ttuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*univec.txt")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.univec.txt"
    """
}

