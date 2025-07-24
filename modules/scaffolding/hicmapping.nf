process hicmapping {

    input:
    tuple val (sample), val (tech) ,val (assembler), val (asmtype),  val (reads), val (fasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (fasta), path ("*.bam")
    path ("*.bai")

    when:
    tech in ["hic"]

    script:

    """
    
    """

    stub:

    """

    touch ${sample}.${asmtype}.${assembler}.hicmapping.bam
    touch ${sample}.${asmtype}.${assembler}.hicmapping.bam.bai
    
    
    """


}