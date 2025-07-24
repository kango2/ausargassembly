process contigtoscaffold {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (fasta), val (hicmapping)

    output:
    tuple val (sample), val (asmtype), val ("yahs"), path ("*.fasta"), path ("*.bin"), path ("*.agp")


    script:

    """
    
    """

    stub:

    """
    
    touch ${sample}.${asmtype}.yahs.fasta
    touch ${sample}.${asmtype}.yahs.bin
    touch ${sample}.${asmtype}.yahs.agp
    
    """


}