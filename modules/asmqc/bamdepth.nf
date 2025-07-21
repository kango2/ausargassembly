process bamdepth {

    publishDir "${params.outdir}/alignreads", mode: 'copy', pattern : "*depth.bed*"

    input:
    tuple val (sample), val (tech), val (asmtype),  val (assembler), val (bam)

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

    touch "${sample}_${tech}_${assembler}_${asmtype}.depth.bed"
    
    """

}
