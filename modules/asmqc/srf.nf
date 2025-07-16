process srf {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (asmfasta), path ("*asm2srf.abun"), path ("*asm2srf.bed"), path ("*asm2srf.paf"), path ("*srf.fa")

    script:
    
    """
    
    """

    stub:

    """
    touch "${sample}_${tech}_${assembler}_${asmtype}.asm2srf.abun"
    touch "${sample}_${tech}_${assembler}_${asmtype}.asm2srf.bed"
    touch "${sample}_${tech}_${assembler}_${asmtype}.asm2srf.paf"
    touch "${sample}_${tech}_${assembler}_${asmtype}.srf.fa"
    """
    
}

