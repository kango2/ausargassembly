process pbindex {

    input:
    tuple val (sample), val (tech), val (runid), val (subread)

    output:
    tuple val (sample), val (tech), val (runid), val (subread)
    path ("indexdone.txt")

    script:

    """  
    pbindex ${subread} -j ${task.cpus}
    touch indexdone.txt
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
    tuple val (sample), val (tech), val (runid), val (subread), path ("${chunk}.ccs.bam"), val (chunk)


    script:

    """

    ccs --min-rq=0.88 -j ${task.cpus} --chunk="${chunk}"/"${params.chunks}" ${subread} "${chunk}.ccs.bam"

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

    actc -j ${task.cpus} ${subread} ${ccs} "${chunk}.subreads_to_ccs.bam"
    """

    stub:

    """
    
    touch "${chunk}.subreads_to_ccs.bam"
    
    """


}

process deepconsensus {

    input:
    tuple val (sample), val (tech), val (runid), val (subread), val (subreads_to_ccs), val (ccs), val (chunk)

    output:
    tuple val (sample), val (tech), val (runid), path ("${chunk}.output.fastq")

    script:
    """

    deepconsensus run --subreads_to_ccs=${subreads_to_ccs} --ccs_bam=${ccs} --checkpoint="/g/data/xl04/ka6418/ausargassembly/deepconsensus/checkpoint" --cpus ${task.cpus} --output=${chunk}.output.fastq 

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
    
    cat ${fastqlist.join(' ')} > "${sample}.${tech}.${runid}.deepconsensus.fastq"
    bgzip -@ ${task.cpus} "${sample}.${tech}.${runid}.deepconsensus.fastq"

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

    cutadapt --cores ${task.cpus} --anywhere file:\${PACBIOADAPTERS} \
    --error-rate 0.1 --overlap 25 --match-read-wildcards --revcomp --discard-trimmed \
    --json "${sample}_${tech}_${runid}.cutadapt.json" \
    -o "${sample}.${tech}.${runid}.deepconsensus.trimmed.fastq.gz" \
    ${fastq}
    
    """

    stub: 

    """
     
    touch "${sample}.${tech}.${runid}.deepconsensus.trimmed.fastq.gz"
    touch cutadapt.json
     
    """


}