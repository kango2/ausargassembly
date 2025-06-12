process pbindex {

    input:
    tuple val (sample), val (tech), val (runid), val (subread)

    output:
    tuple val (sample), val (tech), val (runid), val (subread)
    path ("indexdone.txt")

    script:

    """  
    """

    stub :

    """
    touch indexdone.txt
    """

}

process ccs {

    input:
    tuple val (sample), val (tech), val (runid), val (subread), val (chunk)

    output:
    tuple val (sample), val (tech), val (runid), val (subread), val ("${chunk}.ccs.bam"), val (chunk)


    script:

    """
    
    """

    stub :

    """

    touch "${chunk}.ccs.bam"
    
    """



}

process actc {

    input:
    tuple val (sample), val (tech), val (runid), val (subread), val (ccs), val (chunk)


    output:
    tuple val (sample), val (tech), val (runid), val (subread), path ("${chunk}.subreads_to_ccs.bam"), val (ccs), val (chunk)


    script:

    """
    
    """

    stub:

    """
    
    touch "${chunk}.subreads_to_ccs.bam"
    
    """


}

process deepconsensus {

    input:
    tuple val (sample), val (tech), val (runid), val (subread), val (subreads), val (ccs), val (chunk)

    output:
    tuple val (sample), val (tech), val (runid), path ("${chunk}.output.fastq")

    script:
    """
    
    """


    stub:

    """

    touch "${chunk}.output.fastq"
    
    """


}


process concatFastq {

    input:
    tuple val (sample), val (tech), val (runid), val (fastqlist)

    output:
    tuple val (sample), val (tech), val (runid), path ("${sample}.${tech}.${runid}.deepconsensus.fastq.gz")

    script:

    """
    
    
    """

    stub:
    """

    touch "${sample}.${tech}.${runid}.deepconsensus.fastq.gz"
    
    """

}

process pacbioadaptertrim {

    input:
    tuple val (sample), val (tech), val (runid), val (fastq)

    output:
    tuple val (sample), val (tech), val (runid), path ("${sample}.${tech}.${runid}.deepconsensus.trimmed.fastq.gz")
    path ("*cutadapt.json")

    script:

    """
    
    """

    stub: 

    """
     
    touch "${sample}.${tech}.${runid}.deepconsensus.trimmed.fastq.gz"
    touch cutadapt.json
     
    """


}