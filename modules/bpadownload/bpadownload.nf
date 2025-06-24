

process bpadownload_ont {

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (chemistry), val (passfilename), val (failfilename)

    output:
    tuple val (sample), val (tech), val (runid), val (chemistry), path("*fast5*pass*"), path("*fast5*fail*")

    script:
    """

    unzip ${bpazip}
    mv */* ./
    export CKAN_API_TOKEN="${params.apitoken}"
    bash download.sh -o || true
  
    """

    stub:
    """

    touch "${passfilename}"
    touch "${failfilename}"
    
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

    unzip ${bpazip}
    mv */* ./
    export CKAN_API_TOKEN="${params.apitoken}"
    bash download.sh -o || true
  
    """

    stub:
    """

    touch "${filename}"
    
    """

}


process bpadownload_hic {

    publishDir "${params.bpadata}/${sample}/${tech}/${runid}/raw", pattern : "*fastq.gz", mode: 'copy', overwrite: true

    input:
    tuple val (sample), val (tech), val (runid), val (bpazip), val (r1), val (r2)

    output:
    tuple val (sample), val (tech), val (runid), path("${r1}"), path("${r2}")

    script:
    """

    unzip ${bpazip}
    mv */* ./
    export CKAN_API_TOKEN="${params.apitoken}"
    bash download.sh -o || true
  
    """

    stub:
    """

    touch "${r1}"
    touch "${r2}"
    
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