process merqury {

    input:
    tuple val (sample), val (tech), val (asmtype), val (assembler), val (reads), val (h1), val (h2)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*merqury*")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.merqury.bed"
    """
}

