process contighicmap {

    input:
    tuple val (sample), val(tech) , val (assembler), val (asmtype),  val (reads), val (fasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta), path ("*.hic"), path ("*.assembly")

    when:
    tech in ["hic"]

    script:

    """
    
    """

    stub:

    """

    touch ${sample}.${asmtype}.${assembler}.hic
    touch ${sample}.${asmtype}.${assembler}.assembly
    
    
    """


}