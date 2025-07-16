process bamdepth {

    input:
    tuple val (sample), val (tech), val (asmtype),  val (assembler), val (bam)

    output:
    tuple val (sample), val (tech), val (asmtype),  val (assembler), path ("*.depth.bed")

    script:

    """

    
    """


    stub:

    """

    touch "${sample}_${tech}_${assembler}_${asmtype}.depth.bed"
    
    """

}
