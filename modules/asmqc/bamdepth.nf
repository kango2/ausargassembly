process bamdepth {

    publishDir "${params.outdir}/${sample}/analysis/asmqc/${assembler}/depth/${tech}/${asmtype}", mode: 'copy', pattern : "*depth.bed*"

    input:
    tuple val (sample), val (tech), val (assembler), val (asmtype),   val (bam)

    output:
    tuple val (sample), val (tech), val (asmtype),  val (assembler), path ("*.depth.bed")

    script:

    """

    bam="${bam}"
    export bam 

    window=10000
    export window 

    outdir="\${PWD}"
    export outdir 

    bambase=${sample}.${tech}.${assembler}.${asmtype}
    export bambase

    bash bam_to_bedcov.sh

    """

    stub:

    """

    touch "${sample}.${tech}.${assembler}.${asmtype}.depth.bed"

    """

}
