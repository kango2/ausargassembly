process scaffoldhicmap {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (fasta), val (bin), val (agp)

    output:
    tuple val (sample), val (asmtype), val (assembler), path ("*.hic"), path ("*.assembly")


    script:

    """
    
    """

    stub:

    """

    touch ${sample}.${asmtype}.${assembler}.hic
    touch ${sample}.${asmtype}.${assembler}.assembly
    
    
    """


}