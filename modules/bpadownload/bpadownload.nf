

process bpadownload_ont {

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (chemistry), val (filename)

    output:
    tuple val (sample), val (tech), val (runid), val (chemistry), path("*.fast5")

    script:
    """

    #we will have pass and fail fast5, so download them
    #process them into a single fast5 file
  
    """

    stub:
    """

    touch "${sample}.${tech}.${runid}.fast5"
    
    """

}


process bpadownload_pb {

    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/raw", pattern : "*.subreads.bam", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (filename)

    output:
    tuple val (sample), val (tech), val (runid), path("*.subreads.bam")

    script:
    """

    #we will have a subreads bam directly
  
    """

    stub:
    """

    touch "${sample}.${tech}.${runid}.subreads.bam"
    
    """

}


process bpadownload_hic {

    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/raw", pattern : "*.fastq.gz", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (r1), val (r2)

    output:
    tuple val (sample), val (tech), val (runid), path("*R1*fastq.gz"), path("*R2*fastq.gz")

    script:
    """

    #we will have R1 and R2 fastq.gz files directly
  
    """

    stub:
    """

    touch "${sample}.${tech}.${runid}.R1.fastq.gz"
    touch "${sample}.${tech}.${runid}.R2.fastq.gz"
    
    """

}


process bpadownload_dnaseq {

    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/raw", pattern : "*.fastq.gz", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (r1), val (r2)

    output:
    tuple val (sample), val (tech), val (runid), path("*R1*fastq.gz"), path("*R2*fastq.gz")

    script:
    """

    #we will have R1 and R2 fastq.gz files directly
  
    """

    stub:
    """

    touch "${sample}.${tech}.${runid}.R1.fastq.gz"
    touch "${sample}.${tech}.${runid}.R2.fastq.gz"
    
    """

}