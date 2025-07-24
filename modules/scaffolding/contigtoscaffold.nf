process contigtoscaffolds {

    input:
    tuple val (sample), val (asmtype), val (assembler), val (fasta), val (hicmapping)

    output:
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta), val ("*.fasta")
    tuple val (sample), val (asmtype), val (assembler), val (reads), val (fasta), val ("*.bin")
    val ("*.agp")

    when:
    tech in ["hic"]

    script:

    """
    
    """

    stub:

    """
    
    touch ${sample}.${asmtype}.${assembler}.scaffolds.fasta
    touch ${sample}.${asmtype}.${assembler}.scaffolds.bin
    touch ${sample}.${asmtype}.${assembler}.scaffolds.agp
    
    """


}