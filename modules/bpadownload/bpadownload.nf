

process bpadownload_ont {

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (chemistry), val (passfilename), val (failfilename)

    output:
    tuple val (sample), val (tech), val (runid), val (chemistry), path("*pass*tar"), path("*fail*tar")

    script:
    """

    bash ${bpazip}
  
    """

    stub:
    """

    touch "${sample}.${tech}.${runid}.pass.fast5.tar"
    touch "${sample}.${tech}.${runid}.fail.fast5.tar"
    
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

    bash ${bpazip}
  
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