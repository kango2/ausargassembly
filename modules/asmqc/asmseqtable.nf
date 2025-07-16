process gc {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    ttuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*seqtable.csv")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.seqtable.csv"
    """
}

