process hicmapping {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta), val ("*.bam")
    val ("*.bai")

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