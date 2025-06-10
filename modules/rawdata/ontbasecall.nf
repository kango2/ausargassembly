process ontbasecall {
    
    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/fastx", pattern : "*.fastq.gz", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (chemistry), path (blow5)

    output:
    tuple val (sample), val (tech), val (runid), path("*pass*fastq.gz")
    tuple val (sample), val (tech), val (runid), path("*fail*fastq.gz")

    script:
    """
    # Convert fast5 files to blow5 format using slow5tools
    """

    stub:
    """
    touch "${sample}.${tech}.${runid}.pass.fastq.gz"
    touch "${sample}.${tech}.${runid}.fail.fastq.gz"
    
    """
}