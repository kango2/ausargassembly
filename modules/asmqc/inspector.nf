process inspector {

    input:
    tuple val (sample), val (tech), val (asmtype), val (assembler), val (reads),  val (asmfasta)

    output:
    tuple val (sample), val (tech), val (asmtype),  val (assembler), path("*summary_statistics.txt"), path("*structural_error.bed"), path("*small_scale_error.bed")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.summary_statistics.txt"
    touch "${sample}_${tech}_${assembler}_${asmtype}.structural_error.bed"
    touch "${sample}_${tech}_${assembler}_${asmtype}.small_scale_error.bed"
    """
}

