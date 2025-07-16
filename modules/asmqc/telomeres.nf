//can make one .tdt for chromsyn  - or the chromsyn file can make the tdt
//can make one .bed in general
//and we also need to save TRF? file? 

process telomeres {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*telomeres.bed")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.telomeres.bed"
    """
}

