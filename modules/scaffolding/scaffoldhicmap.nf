process contighicmap {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta), val ("*.hic"), val ("*.assembly")

    when:
    tech in ["hic"]

    script:

    """
    
    """

    stub:

    """

    touch ${sample}.${asmtype}.${assembler}.scaffolds.hic
    touch ${sample}.${asmtype}.${assembler}.scaffolds.assembly
    
    
    """


}